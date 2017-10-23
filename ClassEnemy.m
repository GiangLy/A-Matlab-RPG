classdef ClassEnemy
    % Enemy Class
    
    properties
        lvl
        exp
        hp
    end
    
    methods
        function self = ClassEnemy(varargin)
            % Constructor to create an enemy object based on argument
            % passed in.
            self.lvl = varargin{1};
            self.hp = self.lvl * 10;
            self.exp = self.lvl * 50;
        end
    end
    
end

