DROP DATABASE players_2;
CREATE DATABASE players_2;
USE players_2;

CREATE TABLE players (
  id int(11) NOT NULL AUTO_INCREMENT,
  name TEXT,
  salary DECIMAL(9,2),
  PRIMARY KEY (id)
);

INSERT INTO players (id, name, salary) VALUES (1, "Matthew 'm_giff' Gifford", 89000.00);
INSERT INTO players (id, name, salary) VALUES (2, "Matthew 'Iron Helix' Bouley", 75000.00);
INSERT INTO players (id, name, salary) VALUES (3, "Luke 'Cable Boy' Bouley", 75000.50);

CREATE TABLE games (
  id int(11) NOT NULL AUTO_INCREMENT,
  name TEXT,
  PRIMARY KEY (id)
);

INSERT INTO games (id, name) VALUES (1, 'Eagle Beagle Ballad');
INSERT INTO games (id, name) VALUES (2, 'Camel Tender Redux');
INSERT INTO games (id, name) VALUES (3, 'Super Dunkball II: The Return');
INSERT INTO games (id, name) VALUES (4, 'Turn the Corner SE: CRX vs Porche');

CREATE TABLE wins (
  id int(11) NOT NULL AUTO_INCREMENT,
  player_id int(11) NOT NULL,
  game_id int(11) NOT NULL,
  quantity int(11) NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO wins (player_id, game_id, quantity) VALUES (1, 1, 3);
INSERT INTO wins (player_id, game_id, quantity) VALUES (1, 3, 5);
INSERT INTO wins (player_id, game_id, quantity) VALUES (1, 2, 9);
INSERT INTO wins (player_id, game_id, quantity) VALUES (1, 4, 9);

INSERT INTO wins (player_id, game_id, quantity) VALUES (2, 1, 8);
INSERT INTO wins (player_id, game_id, quantity) VALUES (2, 3, 5);
INSERT INTO wins (player_id, game_id, quantity) VALUES (2, 2, 13);
INSERT INTO wins (player_id, game_id, quantity) VALUES (2, 4, 5);

INSERT INTO wins (player_id, game_id, quantity) VALUES (3, 1, 2);
INSERT INTO wins (player_id, game_id, quantity) VALUES (3, 3, 15);
INSERT INTO wins (player_id, game_id, quantity) VALUES (3, 2, 4);
INSERT INTO wins (player_id, game_id, quantity) VALUES (3, 4, 6);

