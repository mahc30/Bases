CREATE DATABASE primos;
use primos;

create table primos
(
    num int,
    start timestamp,
    end timestamp,
    total timestamp
);

drop procedure n_first_primes;
DELIMITER $$
create procedure n_first_primes(
    lim int
)
BEGIN
   declare num int default 1;
    declare a int default 1;
    declare st timestamp default current_timestamp();
    declare et timestamp default current_timestamp();
    declare diff timestamp;

    while num <= lim
        do
            iteratorLoop:
            while a <= num
                do

                    if (a = num) then
                        set et = current_timestamp();
                        SELECT timediff(et,st) into diff;
                        insert into primos (num, start, end, total) values (num, st, et, diff);
                    elseif (mod(num, a) = 0) then
                        leave iteratorLoop;
                    end if;

                    set a = a + 1;
                end while;
            set a = 2;
            set num = num + 1;
        end while;

    COMMIT;
END $$
DELIMITER ;
