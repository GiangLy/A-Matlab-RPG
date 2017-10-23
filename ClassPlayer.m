classdef ClassPlayer < handle
    % Player Class holds the data for the player.
    
    properties
        name
        lvl
        exp
        hp
        maxhp
        mp
        maxmp
    end
    
    methods
        function self = ClassPlayer(varargin) 
            % Constructor checks to see if existing character data is
            % passed in, if not then new character data is created.
            if isempty(varargin)
                self.name = input('Enter a name: ','s');
                self.lvl = 1;
                self.exp = 0;
                self.hp = 10;
                self.mp = 20;
            else
                self.name = varargin{1};
                self.lvl = varargin{2};
                self.exp = varargin{3};
                self.hp = varargin{4};
                self.mp = varargin{5};
            end
            % Algorithm for max HP and MP based on player level.
                self.maxhp = 10 * self.lvl;                
                self.maxmp = 20 * self.lvl;          
        end
    end
    
    methods
        function levelcheck(self)
            % Checks to see if character has reached maxed lvl.
            if self.lvl < 10
                % If character is not max level and experience needed to
                % level up is reached, increase the characer level by 1,
                % Recalculate the Max HP and MP, and restore HP and MP.
                if self.exp >= (self.lvl * 200)
                    self.exp = self.exp - (self.lvl * 200);
                    self.lvl = self.lvl + 1;
                    fprintf('Leveled UP!\n');
                    self.maxhp = 10 * self.lvl;      
                    self.maxmp = 20 * self.lvl;
                    self.hp = self.maxhp;
                    self.mp = self.maxmp;
                    fprintf('HP and MP restored.\n');
                end
            end
            fprintf('Current Player Level: %d\n',self.lvl);
            fprintf('Current Experience: %d/%d\n',self.exp,self.lvl*200);
        end
        
        function savechar(self)
            % Save character data to a file.
            player = self;
            save('chardata.mat','player');
            fprintf('Game Saved\n');
        end  
    end
    
end
