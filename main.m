function main(exp_type, tgt)
    addpath(genpath('Psychoobox'));
    addpath(genpath('matlab'));

    exp = StateMachine.Factory(exp_type);
    tgt = ParseTgt(tgt, ',');
    exp.Set('tgt', tgt);
    exp.Setup();

    exp.Execute();

    exp.Cleanup();

end
