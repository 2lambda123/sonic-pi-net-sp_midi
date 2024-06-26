-module(sp_midi_test).
-export([start/0, midi_process/0, test_get_current_time_microseconds/2, list_devices/1]).


midi_process() ->
    receive
        {midi_in, Device, <<Midi_event/binary>>} ->
            io:format("Received midi_in message~n->~p: ~p~n", [Device, Midi_event]);
        X ->
            io:format("Received something (not what was expected)->~p~n", [X])

    end,
    midi_process().


test_get_current_time_microseconds(0, _) ->
    done;
test_get_current_time_microseconds(Count, SleepMillis) ->
    T = sp_midi:get_current_time_microseconds(),
    io:fwrite("Time in microseconds: ~p~n", [T]),
    timer:sleep(SleepMillis),
    test_get_current_time_microseconds(Count-1, SleepMillis).

list_devices(0) ->
    done;
list_devices(N) ->
    INS = sp_midi:midi_all_ins(),
    OUTS = sp_midi:midi_outs(),
    io:fwrite("MIDI INs:~p~n", [INS]),
    io:fwrite("MIDI OUTs:~p~n", [OUTS]),
    timer:sleep(1000),
    list_devices(N-1).



start() ->
%    cd("d:/projects/sp_midi/src").
    compile:file(sp_midi),

    %io:fwrite("Testing NIF function to return current time in microseconds. The values should be around 1000 miliseconds away~n"),
    %test_get_current_time_microseconds(3, 1000),

    %Aon = binary:list_to_bin("/*/note_on"),
    %Mon = <<Aon/binary, <<0, 0, 44, 105, 105, 105, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 64, 0, 0, 0, 100>>/binary >>,
    %Aoff = binary:list_to_bin("/*/note_off"),
    %Moff = << Aoff/binary, <<0, 44, 105, 105, 105, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 64, 0, 0, 0, 100>>/binary >>,

    sp_midi:midi_init(),
    sp_midi:midi_open_all_inputs(),
    %sp_midi:midi_open_some_inputs(["nanokey2_1_keyboard_0"]),

    Pid = spawn(sp_midi_test, midi_process, []),
    sp_midi:set_this_pid(Pid),

    %INS = sp_midi:midi_ins(),
    %OUTS = sp_midi:midi_outs(),

    list_devices(10),


    %io:fwrite("MIDI INs:~p~n", [INS]),

    %io:fwrite("MIDI OUTs:~p~n", [OUTS]),

    %io:fwrite("Sending note ON and waiting 3 seconds~n"),
    %sp_midi:midi_send(Mon),

    %timer:sleep(3000),

    %io:fwrite("Sending note OFF~n"),
    %sp_midi:midi_send(Moff),

    io:fwrite("Waiting 10 seconds~n"),
    timer:sleep(10000),

    sp_midi:midi_deinit().
