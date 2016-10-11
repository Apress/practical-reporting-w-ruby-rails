CREATE DATABASE players;
USE players;
CREATE TABLE players (
  id int(11) NOT NULL AUTO_INCREMENT,
  name TEXT,
  wins int(11) NOT NULL,
  salary DECIMAL(9,2),
  PRIMARY KEY (id)
)

