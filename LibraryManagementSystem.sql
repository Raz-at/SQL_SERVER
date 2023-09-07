--create table to add books ie library
create table super(
B_id int  identity(1,1) primary key,
Book varchar(100),
Author varchar(50) ,
tot int ,
)
--add books
insert into super values('One Piece','Luffy',15);
insert into super values('Naruto','Naruto',15);

--create table to enter the name of students who borrow books 
--to take book from library students detail and book name
create table taken(
roll_no int,
name varchar(20),
Book varchar(50),
Author varchar(20),
)

--adding the proession..
ALTER TABLE taken
ADD profession VARCHAR(50) CHECK (profession IN ('student', 'teacher'));

--display the table..
select * from super;
select * from taken;

--to take book from the super table or library
ALTER PROCEDURE addB @roll_no INT, @name VARCHAR(50), @Book VARCHAR(100), @Author VARCHAR(50), @profession VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        DECLARE @count INT;		
        SELECT @count = COUNT(*) FROM taken WHERE name = @name AND profession = @profession;

        IF (@profession = 'teacher' AND @count < 3)
        BEGIN
            BEGIN TRAN;
            
            DECLARE @newTot INT;            
            SELECT @newTot = tot FROM super WHERE Book = @Book AND Author = @Author;

            IF @newTot > 0
            BEGIN
                INSERT INTO taken (roll_no, name, Book, Author, profession) 
                VALUES (@roll_no, @name, @Book, @Author, @profession);

                UPDATE super SET tot = @newTot - 1 
                WHERE Book = @Book AND Author = @Author;
                
                PRINT 'Successful';
                COMMIT TRAN;
            END
            ELSE
            BEGIN
                PRINT 'No book';
                ROLLBACK TRAN;
            END
        END
        ELSE IF (@profession = 'student' AND @count < 2)
        BEGIN
            BEGIN TRAN;            
            SELECT @newTot = tot FROM super WHERE Book = @Book AND Author = @Author;

            IF @newTot > 0
            BEGIN
                INSERT INTO taken (roll_no, name, Book, Author, profession) 
                VALUES (@roll_no, @name, @Book, @Author, @profession);

                UPDATE super SET tot = @newTot - 1 
                WHERE Book = @Book AND Author = @Author;
                
                PRINT 'Successful';
                COMMIT TRAN;
            END
            ELSE
            BEGIN
                PRINT 'No book';
                ROLLBACK TRAN;
            END
        END
        ELSE
        BEGIN
            PRINT 'Enough';
        END
    END TRY
    
    BEGIN CATCH
        ROLLBACK TRAN;
        PRINT 'Failed';
    END CATCH
END;


EXEC addB @roll_no=106, @name = 'OPK', @Book = 'Naruto', @Author = 'Naruto' , @profession='teacher';

select * from super;
select * from taken;

--to return book to the library....
ALTER PROCEDURE delB @roll_no INT, @name VARCHAR(50), @Book VARCHAR(100), @Author VARCHAR(50) 
AS
BEGIN
    BEGIN TRY
        DECLARE @delTot INT;
        SET @delTot = (SELECT COUNT(*) FROM taken WHERE name = @name AND Book = @Book AND Author = @Author);

        IF (@delTot > 0)
        BEGIN
            BEGIN TRAN;

				DELETE TOP (1) FROM taken WHERE name = @name AND Book = @Book AND Author = @Author;

				UPDATE super SET tot = tot + 1 WHERE Book = @Book AND Author = @Author;

            COMMIT TRAN;
        END
        ELSE
        BEGIN
            PRINT 'No books under this name';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
    END CATCH
END;

EXEC delB @roll_no=100 ,@name = 'PK' , @Book='Naruto' , @Author ='Oda'

--to view the library and students who have books
select * from super;
select * from taken;




