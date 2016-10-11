DELETE FROM actors;
DELETE FROM projects;
DELETE FROM rooms;
DELETE FROM bookings;

INSERT INTO actors (id, name) VALUES
                   (1, 'Jim Thompson');
INSERT INTO actors (id, name) VALUES
                   (2, 'Becky Leuser');
INSERT INTO actors (id, name) VALUES
                   (3, 'Elizabeth Berube');
INSERT INTO actors (id, name) VALUES
                   (4, 'Dave Guuseman');
INSERT INTO actors (id, name) VALUES
                   (5, 'Tom Jimson');

INSERT INTO projects (id, name) VALUES
                     (1, 'Turbo Bowling Intro Sequence');
INSERT INTO projects (id, name) VALUES
                     (2, 'Seven for Dinner Win Game Sequence');
INSERT INTO projects (id, name) VALUES
                     (3, 'Seven for Dinner Lost Game Sequence');

INSERT INTO rooms (id, name) VALUES
                  (1, 'L120, Little Hall');
INSERT INTO rooms (id, name) VALUES
                  (2, 'L112, Little Hall');
INSERT INTO rooms (id, name) VALUES
                  (3, 'M120, Tech Center');

INSERT INTO bookings (actor_id, room_id, project_id, booked_at) VALUES
                     (1,1,2, DATE_ADD( NOW(), INTERVAL 3 HOUR ));
INSERT INTO bookings (actor_id, room_id, project_id, booked_at) VALUES
                     (1,1,3, DATE_ADD( NOW(), INTERVAL 4 HOUR ));
INSERT INTO bookings (actor_id, room_id, project_id, booked_at) VALUES
                     (3,2,2, DATE_ADD( NOW(), INTERVAL 1 DAY ));
INSERT INTO bookings (actor_id, room_id, project_id, booked_at) VALUES
                     (2,3,1, DATE_ADD( NOW(), INTERVAL 5 HOUR ));
INSERT INTO bookings (actor_id, room_id, project_id, booked_at) VALUES
                     (4,1,2, DATE_ADD( NOW(), INTERVAL 10 HOUR ));
INSERT INTO bookings (actor_id, room_id, project_id, booked_at) VALUES
                     (5,3,1, DATE_ADD( NOW(), INTERVAL 1 HOUR ));

