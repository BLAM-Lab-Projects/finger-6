function main(exp_type, tgt_name)
    addpath(genpath('Psychoobox'));
    addpath(genpath('matlab'));
    addpath(genpath('ptbutils'));
    
    try
        exp = StateMachine.Factory(exp_type);
        tgt = ParseTgt(tgt_name, ',');
        exp.Set('tgt', tgt);
        exp.Setup();

        exp.Execute();

        exp.Cleanup();
    catch ME
        % save data!
        BailPtb;
        rethrow(ME);
    end
end
