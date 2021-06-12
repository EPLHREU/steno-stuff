% Phrase analyser for large amounts of text data
% run with p2:go("Text", WordLengthToAnalyseUpTo, ThreadsToSpawn).
% you may need to adjust the "sa" function to change how the "Score" variable is defined 
% this will lead to better results on some datasets

-module(p2).
-compile([export_all]).
%-on_load(headless/0).

headless() ->
	File = "bee.txt",
	Number = 6,
	Thread = 1,
	go(File, Number, Thread).


go(FileName, Number, Threads) ->
	%fprof:trace(start),
	Aggregator = spawn(?MODULE, aggregator, [FileName, Threads, dict:new()]),
	Pids = [spawn(?MODULE, worker,
		      [ dict:store(all, {0, dict:new()}, dict:new() ) ])
		|| _ <- lists:seq(1, Threads) ],
	Distributor = spawn(?MODULE, distributor, [1, Threads, Pids,
						   queue:from_list(
						     [ " " || _ <- lists:seq(1,Number)]
						    )]),
	{ok, F} = file:open(FileName, [read, raw, read_ahead]),
	sendWord(F, Pids, Distributor, Aggregator).

sendWord(F, Pids, Distributor, Aggregator) ->
	Output = file:read_line(F),
	case Output of
		eof ->
			Distributor ! {eof, Aggregator},
			io:format("sendWord - all words read and sent~n");
		{ok, Line} ->
			%spawn(fun() ->
			Words = string:lexemes(Line, " \n\t"),
			[ Distributor ! {word, Word} || Word <- Words ],
			%      end),

			%[Distributor ! {word, Word} ||  Word <- Words],
			sendWord(F, Pids, Distributor, Aggregator)
	end.

queuePush(Queue, In) ->
	%io:format("queuePush - Queue : ~p - In : ~p~n", [Queue, In]),
	{_, ShortQueue} = queue:out(Queue),
	{value, Peek} = queue:peek(ShortQueue),
	NewQueue = queue:in(In, ShortQueue),
	List = queue:to_list(NewQueue),
	{Peek, NewQueue, List}.

distributor(Count, High, Pids, Queue) when Count =< High ->
	receive 
		{word, Word} ->
			{Peek, NewQueue, List} = queuePush(Queue, Word),
			%io:format("distributor - Peek : ~p~n", [Peek]),
			if Peek =/= " " ->
				   Pid = lists:nth(Count, Pids),
				   %io:format("distributor - Pids : ~p - Count : ~p - Pid : ~p~n", [Pids, Count, Pid]),
				   %io:format("distributor - List : ~p~n", [List]),
				   Pid ! {list, List};
			   true -> 
				   ok
			end,
			distributor(Count + 1, High, Pids, NewQueue);
		{eof, Aggregator} ->
			[Pid ! {eof, Aggregator} || Pid <- Pids]
	end;
distributor(_Count, High, Pids, Queue) ->
	distributor(1, High, Pids, Queue).

store([Word|Phrase], Store) when Word =/= [] ->
	%io:format("store - Word : ~p - Phrase : ~p~n", [Word, Phrase]),
	dict:update(Word,
		    fun({Count, Next}) ->
				    SubStore = store(Phrase, Next),
				    {Count + 1, SubStore}
		    end,
		    {1, store(Phrase, dict:new())},
		    Store);
store(_List, Store) ->
	Store.

storeSort(List) ->
	lists:sort(fun({_, A, _}, {_, B, _}) -> A =< B end, List).


worker(Dict) ->
	receive
		{list, List} ->
			{Count, Store} = dict:fetch(all, Dict),
			%io:format("worker - List : ~p~n", [List]),
			NewStore = store(List, Store),
			NewDict = dict:store(all, {Count + 1, NewStore}, Dict),
			worker(NewDict);
		{eof, Pid} ->
			%List = [ {Key, Count, dict:to_list(Dict)} || {Key, {Count, Dict}} <- dict:to_list(Store)],
			%io:format("~p~n", [List])
			Pid ! {store, Dict},
			%io:format("worker - Dict : ~p~n", [storeList(Dict)]),
			io:format("worker - length phrases computed~n")
	end.

is_dict(D) ->
	if is_tuple(D) ->
		   Dict = element(1, D),
		   Dict == dict;
	   true -> false
	end.

storeMerge(A, B)  ->
	%io:format("storeMerge - A : ~p - B : ~p~n", [storeList(A), storeList(B)]),
	dict:merge(
	  fun(_Key, {CA, DA}, {CB, DB}) ->
			  {CA + CB, storeMerge(DA, DB)}
	  end,
	  A, B).

storeList(Store) ->
	case is_dict(Store) of
		true ->
			List = dict:to_list(Store),
			[ {{Key, Value}, storeList(Item)} || {Key, {Value, Item}} <- List];
		false ->
			Store
	end.

storeAnalyseLowerCount(Dict, Total) ->
	%io:format("SALC - Dict : ~p~n", [Dict]),
	%io:format("SALC - Dict : ~p~n", [storeList(Dict)]),
	case dict:is_empty(Dict) of
		true ->
			%io:format("SALC - empty~n"),
			0;
		false ->
			%io:format("SALC - full~n"),
			Val = dict:fold(fun(_Key, {Value, _}, Acc) ->
							Percent = 100 / Total * Value,
							%io:format("SALC - Percent : ~p~n", [Percent]),
							if Percent < 5 -> Acc;
							   true -> Acc + Value
							end
					end,
					0,
					Dict),
			if Val == [] -> 1;
			   true -> Val
			end
	end.

storeAnalyse(Store) ->
	{_Count, Data} = dict:fetch(all, Store),
	sa([], Data, 0).

sa(Phrase, Next, Length) ->
	%io:format("sa - Total : ~p - Phrase : ~p~n", [Total, Phrase]),
	dict:fold(fun(Key, {Count, Dict}, Acc) ->
				  %io:format("sa - self() : ~p~n", [self()]),
				  %io:format("sa - Total : ~p - Phrase : ~p - Key : ~p - Count : ~p~n", [Total, Phrase, Key, Count]),
				  %if Last == top -> Total = 1;
				  %   true -> Total = Last
				  %end,
				  if Key == " " ->
					     Acc;
				     true -> 
							     Parent = self(),
							     Spawn = spawn(fun() -> SubAcc = sa( [Key | Phrase], Dict, Length + 1),
											   Parent ! {subAcc, self(), SubAcc} end),
							     Score = round(Count * math:log2(Length + 2)),
							     String = lists:concat(lists:join(" ", lists:reverse([Key|Phrase]))),
							     receive 
								     {subAcc, Spawn, SubAcc} ->
									     lists:append([{String, Score, Count} | Acc], SubAcc)
							     end
				  end
		  end,
		  [],
		  Next).

aggregator(FileName, Count, Store) ->
	case Count of
		0 ->
			io:format("aggregator - results merged~n"),
			%io:format("aggregator - Store : ~p~n", [storeList(Store)]),
			List = storeAnalyse(Store),
			Results = storeSort(List),
			{ok, Save} = file:open(FileName ++ "-results.csv", write),
			io:format(Save, "~s~n", ["phrase	weight	count"]),
			[io:format(Save, "~s\t~p\t~p~n", [Phrase, Weight, Times])
			 || {Phrase, Weight, Times} <- Results],
			io:format("aggregator - results aggregated and saved~n"),
			fin();
		_ ->
			receive
				{store, NewStore} ->
					%io:format("aggregator - Count : ~p~n", [Count]),
					Merge = storeMerge(NewStore, Store),
					aggregator(FileName, Count - 1, Merge)
			end
	end.

fin() ->
	done.
%fprof:trace(stop),
%fprof:profile(),
%fprof:analyse(dest, []).
