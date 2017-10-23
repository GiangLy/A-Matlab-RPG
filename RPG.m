classdef RPG < handle
    % RPG This is the class definition of the main game. Once player data is
    % loaded/created successfully. Use play function to begin the game.
    
    %Defining the properties of class RPG
    properties
        PlayerObj
        location
        encounter
        boss_state
        win
    end
    
    methods
        % Default constructor
        function self = RPG(varargin)
            clc;
            if isempty(varargin)
                % Checks to see if character data exists or not.
                if exist('chardata.mat', 'file') == 2
                    fprintf('Character data file found\n');
                    choice = ' ';
                    % If Character data is found, prompts to load or create new
                    % character.
                    while ~strcmp(choice,'y') && ~strcmp(choice,'n')
                        choice = input('load file? (y/n)','s');
                    end
                    if strcmp(choice,'y')
                        % Load character data and create new Player Object
                        % using the data.
                        temp = load('chardata.mat');
                        self.PlayerObj = ClassPlayer(temp.player.name,temp.player.lvl,temp.player.exp,temp.player.hp,temp.player.mp);
                        fprintf('Game Loaded Successfully\n');
                    else
                        % Create a new Player object and save the character
                        % data to new file.
                        self.PlayerObj = ClassPlayer();
                        savechar(self.PlayerObj);
                    end
                else
                    % If no character data is found, Create a new Player object
                    % and save the character data to new file.
                    fprintf('Character Data not found. Creating new character.\n');
                    self.PlayerObj = ClassPlayer();
                    savechar(self.PlayerObj);
                end
                self.location.x = 845;
                self.location.y = 1015;
                self.encounter = 0;
                self.boss_state = 1;
            else
                self.PlayerObj = varargin{1};
                self.boss_state = varargin{2};
                self.location.x = varargin{3};
                self.location.y = varargin{4};
            end
            % Displays Character data
            fprintf('Name: %s\n',self.PlayerObj.name);
            fprintf('Level: %d\n',self.PlayerObj.lvl);
            fprintf('Current Health: %d\n',self.PlayerObj.hp);
            fprintf('Max Health: %d\n',self.PlayerObj.maxhp);
            fprintf('Current Mana: %d\n',self.PlayerObj.mp);
            fprintf('Max Mana: %d\n',self.PlayerObj.maxmp);
        end
    end
    
    methods
        % Starts game using the Player object data.
        function play(self)
            choice = ' ';
            self.win = 0;
            % Display Game map and displays current stats in console.
            % Prompts user for input. Either Save, exit, or a direction to
            % move on the map.
            while self.PlayerObj.hp > 0 && ~strcmp(choice,'EXIT') && self.boss_state == 1
                clc;
                self.gamestate
                fprintf('Current Stats\n');
                fprintf('-----------------------\n');
                fprintf('Player Current Level: %.2d/10\n',self.PlayerObj.lvl);
                fprintf('Player Current EXP: %.2d/%.2d\n',self.PlayerObj.exp,self.PlayerObj.lvl * 200);
                fprintf('Player Current HP: %.2f/%.2f\n',self.PlayerObj.hp,self.PlayerObj.maxhp);
                fprintf('Player Current MP: %.2f/%.2f\n',self.PlayerObj.mp,self.PlayerObj.maxmp);
                fprintf('-----------------------\n');
                fprintf('Type SAVE to save character data.\n');
                fprintf('Type EXIT to quit game.\n');
                choice = input('Which direction do you want to go? (N/S/E/W):','s');
                % If the user input is a direction, move the character
                % location accordingly on the map. Check to see if an enemy
                % encounter is triggered. If not then increase the chance
                % of enemy encounter.
                if strcmp(choice,'N') && self.location.y > 70
                    self.location.y = self.location.y - 45;
                    self.encounter = self.encounter + .1;
                    self.battle
                elseif strcmp(choice,'S') && self.location.y < 1015
                    self.location.y = self.location.y + 45;
                    self.encounter = self.encounter + .1;
                    self.battle
                elseif strcmp(choice,'E') && self.location.x < 980
                    self.location.x = self.location.x + 45;
                    self.encounter = self.encounter + .1;
                    self.battle
                elseif strcmp(choice,'W') && self.location.x > 80
                    self.location.x = self.location.x - 45;
                    self.encounter = self.encounter + .1;
                    self.battle
                elseif strcmp(choice,'SAVE')
                    savechar(self.PlayerObj);
                    fprintf('Press any key.\n');
                    pause;
                elseif strcmp(choice,'EXIT')
                    fprintf('Exiting Game...\n');
                else
                    fprintf('Not Valid input\n');
                    fprintf('Press any key.\n');
                    pause;
                end
            end
            % There are three conditions to exit the game.
            % 1. The player's HP is less than or equal to 0 (Defeat)
            % 2. The boss_state flag is 0 (Victory)
            % 3. User input EXIT (Exit the game)
            if self.PlayerObj.hp <= 0
                fprintf('You have been defeated.\n');
                fprintf('Game Over.\n');
            end
            
            if self.boss_state == 0 && self.location.x == 980 && self.location.y == 70
                self.win = 1;
            elseif self.boss_state == 0 && (self.location.x ~= 980 || self.location.y ~= 70)
                self.win = 2;
            end
            
            if self.win == 1
                fprintf('You have defeated the BOSS.\n');
                fprintf('YOU WIN! CONGRATULATIONS!\n');
            elseif self.win == 2
                fprintf('Cheat detected.\n');
            end
            
        end
        
        function gamestate(self)
            close all
            % Display a Map image on a figure. And plot character location
            % on same figure. 
            I = imread('Map.png');
            imshow(I);
            hold on
            plot(self.location.x,self.location.y,'g*','MarkerSize',15);
            plot(980,70,'r*','MarkerSize',15);
        end
        
        function battle(self)
            % Checks to see if encounter is triggered or not.
            format short;
            r = rand;
            if r < self.encounter || (self.location.x == 980 && self.location.y == 70)
                % If player location is at boss location, trigger boss
                % fight. Boss fight is an encounter with an enemy level 12.
                % Max acheivable player level is 10.
                if self.location.x == 980 && self.location.y == 70
                    fprintf('BOSS encountered: Press any key to begin battle.\n');
                    pause;
                    EnemyObj = ClassEnemy(12);
                else
                    % If player location is not at the boss location,
                    % trigger fight with normal enemy. Enemy level is the
                    % same level as player level.
                    fprintf('Enemy encountered: Press any key to begin battle.\n');
                    pause;
                    EnemyObj = ClassEnemy(self.PlayerObj.lvl);
                end
                while EnemyObj.hp > 0 && self.PlayerObj.hp > 0
                    clc;
                    % Display Enemy HP as well as player's current stats.
                    fprintf('Enemy Current HP: %.2f\n',EnemyObj.hp);
                    fprintf('-----------------------\n');
                    fprintf('Player Current HP: %.2f/%.2f\n',self.PlayerObj.hp,self.PlayerObj.maxhp);
                    fprintf('Player Current MP: %.2f/%.2f\n',self.PlayerObj.mp,self.PlayerObj.maxmp);
                    %------------------------------------------------------
                    % Action menu is displayed. Attack will perform a
                    % normal attack. This attack does not use any MP. Magic
                    % is a magic attack that uses MP and is generally
                    % stronger than a normal attack. Heal will restore HP
                    % at the cost of MP. Run is a flat %50 chance to escape
                    % from the current battle. No experience is awarded if
                    % player is able to escape.
                    % -----------------------------------------------------
                    fprintf('Menu\n');
                    fprintf('------------\n');
                    fprintf('1. Attack\n');
                    fprintf('2. Magic\n');
                    fprintf('3. Heal\n');
                    fprintf('4. Run\n');
                    choice = input('What to do:');
                    if choice == 1
                        % Normal attack power based on player level. 
                        damage = self.PlayerObj.lvl*(.5*rand + .5);
                        EnemyObj.hp = EnemyObj.hp - damage;
                        fprintf('You attacked for %.2f damage.\n',damage);
                        pause(1);
                        % Checks to see if Enemy is defeated or not. If
                        % enemy HP is less than or equal to zero, exit
                        % battle and award experience.
                        if EnemyObj.hp <= 0
                            fprintf('Enemy Defeated!\n');
                            fprintf('Gained %d Experience Points!\n',EnemyObj.exp);
                            self.PlayerObj.exp = self.PlayerObj.exp + EnemyObj.exp;
                            levelcheck(self.PlayerObj);
                        else
                            % If enemy HP > 0, the enemy will counter
                            % attack.
                            damage = EnemyObj.lvl*(.2*rand + .2);
                            self.PlayerObj.hp = self.PlayerObj.hp - damage;
                            fprintf('Enemy attacked for %.2f damage.\n',damage);
                        end
                    elseif choice == 2
                        % Checks to make sure player has enough MP to
                        % perform a Magic attack.
                        if self.PlayerObj.mp > (self.PlayerObj.lvl * 1.5)
                            damage = (self.PlayerObj.lvl + 2)*(.5*rand + .5);
                            EnemyObj.hp = EnemyObj.hp - damage;
                            fprintf('Your magic dealt %.2f damage.\n',damage);
                            self.PlayerObj.mp = self.PlayerObj.mp - (self.PlayerObj.lvl * 1.5);
                            pause(1);
                            if EnemyObj.hp <= 0
                                fprintf('Enemy Defeated!\n');
                                fprintf('Gained %d Experience Points!\n',EnemyObj.exp);
                                self.PlayerObj.exp = self.PlayerObj.exp + EnemyObj.exp;
                                levelcheck(self.PlayerObj);
                            else
                                damage = EnemyObj.lvl*(.2*rand + .2);
                                self.PlayerObj.hp = self.PlayerObj.hp - damage;
                                fprintf('Enemy attacked for %.2f damage.\n',damage);
                            end
                        else
                            fprintf('Not Enough MP\n');
                        end
                        
                    elseif choice == 3
                        % Checks to make sure player has enough MP to
                        % perform a heal. If player is at max HP, the heal
                        % will not be casted. Cannot heal for more than max
                        % HP.
                        if self.PlayerObj.mp > (self.PlayerObj.lvl) && self.PlayerObj.hp < self.PlayerObj.maxhp
                            heal = (self.PlayerObj.lvl + 1)*(.5*rand + .5);
                            if (self.PlayerObj.hp + heal) > self.PlayerObj.maxhp
                                heal = self.PlayerObj.maxhp - self.PlayerObj.hp;
                            end
                            self.PlayerObj.hp = self.PlayerObj.hp + heal;
                            fprintf('You healed for %.2f hit points.\n',heal);
                            self.PlayerObj.mp = self.PlayerObj.mp - self.PlayerObj.lvl;
                            pause(1);
                            damage = EnemyObj.lvl*(.2*rand + .2);
                            self.PlayerObj.hp = self.PlayerObj.hp - damage;
                            fprintf('Enemy attacked for %.2f damage.\n',damage);
                        elseif self.PlayerObj.hp < self.PlayerObj.maxhp
                            fprintf('HP is already at max.\n');
                        else
                            fprintf('Not Enough MP\n');
                        end
                    elseif choice == 4
                        % Try to escape %50.
                        r = rand;
                        if r < .5
                            fprintf('Successfully Escaped!\n');
                            EnemyObj.hp = 0;
                        else
                            % If escape fails, the enemy will counter
                            % attack.
                            fprintf('Escape failed.\n');
                            pause(1);
                            damage = EnemyObj.lvl*(.2*rand + .2);
                            self.PlayerObj.hp = self.PlayerObj.hp - damage;
                            fprintf('Enemy attacked for %.2f damage.\n',damage);
                        end
                        
                    else
                        fprintf('Invalid Selection\n');
                    end
                    fprintf('Press any key.\n');
                    pause;
                end
                % Resets the encounter rate back to zero.
                self.encounter = 0;
            end
            
        end
        
    end
end