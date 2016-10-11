DROP  DATABASE IF EXISTS players_3 ;
CREATE DATABASE players_3;
USE players_3;

CREATE TABLE players (
  id int(11) NOT NULL AUTO_INCREMENT,
  name TEXT,
  drink TEXT,
  salary DECIMAL(9,2),
  PRIMARY KEY (id)
);

INSERT INTO players (id, name, drink, salary) VALUES 
                    (1, "Matthew 'm_giff' Gifford", "Moxie", 89000.00);
INSERT INTO players (id, name, drink, salary) VALUES 
                    (2, "Matthew 'Iron Helix' Bouley", "Moxie", 75000.00);
INSERT INTO players (id, name, drink, salary) VALUES 
                    (3, "Luke 'Cable Boy' Bouley", "Moxie", 75000.50);
INSERT INTO players (id, name, drink, salary) VALUES 
                    (4, "Andrew 'steven-tyler-xavier' Thomas", 'Fresca', 75000.50);
INSERT INTO players (id, name, drink, salary) VALUES 
                    (5, "John 'dwy_dwy' Dwyer", 'Fresca', 89000.00);
INSERT INTO players (id, name, drink, salary) VALUES 
                    (6, "Ryan 'the_dominator' Peacan", 'Fresca', 75000.50);
INSERT INTO players (id, name, drink, salary) VALUES 
                    (7, "Michael 'Shaun Wiki' Southwick", 'Fresca', 75000.50);

CREATE TABLE games (
  id int(11) NOT NULL AUTO_INCREMENT,
  name TEXT,
  PRIMARY KEY (id)
);

INSERT INTO games (id, name) VALUES (1, 'Bubble Recyler');
INSERT INTO games (id, name) VALUES (2, 'Computer Repair King');
INSERT INTO games (id, name) VALUES (3, 'Super Dunkball II: The Return');
INSERT INTO games (id, name) VALUES (4, 'Sudden Decelleration: No Time to Think');

CREATE TABLE wins (
  id int(11) NOT NULL AUTO_INCREMENT,
  player_id int(11) NOT NULL,
  game_id int(11) NOT NULL,
  quantity int(11) NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO wins (player_id, game_id, quantity) VALUES (1, 1, 3);
INSERT INTO wins (player_id, game_id, quantity) VALUES (1, 3, 8);
INSERT INTO wins (player_id, game_id, quantity) VALUES (1, 2, 3);
INSERT INTO wins (player_id, game_id, quantity) VALUES (1, 4, 9);

INSERT INTO wins (player_id, game_id, quantity) VALUES (2, 1, 8);
INSERT INTO wins (player_id, game_id, quantity) VALUES (2, 3, 10);
INSERT INTO wins (player_id, game_id, quantity) VALUES (2, 2, 7);
INSERT INTO wins (player_id, game_id, quantity) VALUES (2, 4, 5);

INSERT INTO wins (player_id, game_id, quantity) VALUES (3, 1, 8);
INSERT INTO wins (player_id, game_id, quantity) VALUES (3, 3, 4);
INSERT INTO wins (player_id, game_id, quantity) VALUES (3, 2, 20);
INSERT INTO wins (player_id, game_id, quantity) VALUES (3, 4, 8);

INSERT INTO wins (player_id, game_id, quantity) VALUES (4, 1, 8);
INSERT INTO wins (player_id, game_id, quantity) VALUES (4, 3, 9);
INSERT INTO wins (player_id, game_id, quantity) VALUES (4, 2, 6);
INSERT INTO wins (player_id, game_id, quantity) VALUES (4, 4, 3);

INSERT INTO wins (player_id, game_id, quantity) VALUES (5, 1, 7);
INSERT INTO wins (player_id, game_id, quantity) VALUES (5, 3, 1);
INSERT INTO wins (player_id, game_id, quantity) VALUES (5, 2, 9);
INSERT INTO wins (player_id, game_id, quantity) VALUES (5, 4, 4);

INSERT INTO wins (player_id, game_id, quantity) VALUES (6, 1, 2);
INSERT INTO wins (player_id, game_id, quantity) VALUES (6, 3, 10);
INSERT INTO wins (player_id, game_id, quantity) VALUES (6, 2, 8);
INSERT INTO wins (player_id, game_id, quantity) VALUES (6, 4, 9);

INSERT INTO wins (player_id, game_id, quantity) VALUES (7, 1, 2);
INSERT INTO wins (player_id, game_id, quantity) VALUES (7, 3, 1);
INSERT INTO wins (player_id, game_id, quantity) VALUES (7, 2, 4);
INSERT INTO wins (player_id, game_id, quantity) VALUES (7, 4, 9);

