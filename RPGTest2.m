classdef RPGTest2 < matlab.unittest.TestCase
% Test Case where boss has been defeated and player location is in the
% correct location.
    
    methods (Test)
        function TestXWin(testCase)
            expSol = 1;
            player1 = ClassPlayer('Test',10,0,100,200);
            h = RPG(player1,0,980,70);
            h.play
            actSol = h.win;
            testCase.verifyEqual(actSol,expSol)
        end
    end
    
end
