function main(exp_type, tgt)
    addpath(genpath('Psychoobox'));

    exp = StateMachine.Factory(exp_type);
    tgt = ParseTgt(tgt, ',');
    exp.Set('tgt', tgt);
    

end
