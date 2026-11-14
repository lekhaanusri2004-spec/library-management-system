
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management CHARACTER SET utf8mb4;
USE library_management;

SELECT DATABASE() AS current_database;
-- EXPECTED OUTPUT: 1 row. current_database = library_management

-- ============================================================================
-- PART 2 - TABLE CREATION (instructor's DDL, unchanged)
-- ============================================================================
-- Creation order respects the foreign keys: parents first, children last.

CREATE TABLE Books (
book_id INT PRIMARY KEY,
title VARCHAR(150) NOT NULL,
author VARCHAR(100),
publisher VARCHAR(100),
category VARCHAR(50),
price DECIMAL(10,2),
availability_status VARCHAR(20)
);

CREATE TABLE Members (
member_id INT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE,
phone VARCHAR(15),
address VARCHAR(255),
membership_date DATE
);

CREATE TABLE Librarians (
librarian_id INT PRIMARY KEY,
name VARCHAR(100),
phone VARCHAR(15),
joining_date DATE
);

CREATE TABLE Borrow_Records (
borrow_id INT PRIMARY KEY,
member_id INT,
book_id INT,
librarian_id INT,
borrow_date DATE,
return_date DATE,
status VARCHAR(20),
FOREIGN KEY (member_id) REFERENCES Members(member_id),
FOREIGN KEY (book_id) REFERENCES Books(book_id),
FOREIGN KEY (librarian_id) REFERENCES Librarians(librarian_id)
);

CREATE TABLE Reservations (
reservation_id INT PRIMARY KEY,
member_id INT,
book_id INT,
reservation_date DATE,
FOREIGN KEY (member_id) REFERENCES Members(member_id),
FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- Verify the tables.
SHOW TABLES;
-- EXPECTED OUTPUT: 5 rows: Books, Borrow_Records, Librarians, Members, Reservations
--   (on Windows servers the names may appear in lower case)

-- Verify the five foreign keys.
SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'library_management' AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;
-- EXPECTED OUTPUT: 5 rows
--     Borrow_Records | book_id      | Books      | book_id
--     Borrow_Records | librarian_id | Librarians | librarian_id
--     Borrow_Records | member_id    | Members    | member_id
--     Reservations   | book_id      | Books      | book_id
--     Reservations   | member_id    | Members    | member_id

-- ============================================================================
-- PART 3 - SAMPLE DATA INSERTION (Basic Query 1)
-- ============================================================================
-- Insert order respects the foreign keys: Books, Members, Librarians,
-- then Borrow_Records and Reservations.
-- Counts: Books 100, Members 100, Librarians 10, Borrow_Records 200, Reservations 60.

-- ---- 3.1 Books (100 rows: 70 Available, 30 Issued)
INSERT INTO Books (book_id, title, author, publisher, category, price, availability_status) VALUES
(1, 'To Kill a Mockingbird', 'Harper Lee', 'HarperCollins', 'Fiction', 299.00, 'Available'),
(2, '1984', 'George Orwell', 'Penguin Random House India', 'Fiction', 399.00, 'Available'),
(3, 'The Great Gatsby', 'F. Scott Fitzgerald', 'Penguin Random House India', 'Fiction', 249.00, 'Issued'),
(4, 'Pride and Prejudice', 'Jane Austen', 'Penguin Random House India', 'Fiction', 199.00, 'Available'),
(5, 'The Kite Runner', 'Khaled Hosseini', 'Bloomsbury', 'Fiction', 449.00, 'Available'),
(6, 'Life of Pi', 'Yann Martel', 'Penguin Random House India', 'Fiction', 399.00, 'Issued'),
(7, 'The Alchemist', 'Paulo Coelho', 'HarperCollins', 'Fiction', 349.00, 'Available'),
(8, 'One Hundred Years of Solitude', 'Gabriel Garcia Marquez', 'Penguin Random House India', 'Fiction', 499.00, 'Available'),
(9, 'The God of Small Things', 'Arundhati Roy', 'Penguin Random House India', 'Fiction', 550.00, 'Available'),
(10, 'Midnight''s Children', 'Salman Rushdie', 'Penguin Random House India', 'Fiction', 599.00, 'Available'),
(11, 'The White Tiger', 'Aravind Adiga', 'HarperCollins', 'Fiction', 349.00, 'Issued'),
(12, 'Train to Pakistan', 'Khushwant Singh', 'Penguin Random House India', 'Fiction', 249.00, 'Available'),
(13, 'The Namesake', 'Jhumpa Lahiri', 'HarperCollins', 'Fiction', 399.00, 'Issued'),
(14, 'Brave New World', 'Aldous Huxley', 'Penguin Random House India', 'Fiction', 299.00, 'Available'),
(15, 'Animal Farm', 'George Orwell', 'Penguin Random House India', 'Fiction', 199.00, 'Available'),
(16, 'The Catcher in the Rye', 'J. D. Salinger', 'Penguin Random House India', 'Fiction', 349.00, 'Available'),
(17, 'Beloved', 'Toni Morrison', 'Penguin Random House India', 'Fiction', 500.00, 'Issued'),
(18, 'Wuthering Heights', 'Emily Bronte', 'Penguin Random House India', 'Fiction', 299.00, 'Available'),
(19, 'Sapiens', 'Yuval Noah Harari', 'Penguin Random House India', 'Non-Fiction', 499.00, 'Available'),
(20, 'Educated', 'Tara Westover', 'Penguin Random House India', 'Non-Fiction', 599.00, 'Available'),
(21, 'The Immortal Life of Henrietta Lacks', 'Rebecca Skloot', 'Pan Macmillan', 'Non-Fiction', 449.00, 'Available'),
(22, 'Outliers', 'Malcolm Gladwell', 'Penguin Random House India', 'Non-Fiction', 500.00, 'Issued'),
(23, 'Freakonomics', 'Steven D. Levitt and Stephen J. Dubner', 'HarperCollins', 'Non-Fiction', 399.00, 'Issued'),
(24, 'Guns, Germs, and Steel', 'Jared Diamond', 'W. W. Norton', 'Non-Fiction', 549.00, 'Available'),
(25, 'Quiet', 'Susan Cain', 'Penguin Random House India', 'Non-Fiction', 429.00, 'Issued'),
(26, 'The Tipping Point', 'Malcolm Gladwell', 'Hachette India', 'Non-Fiction', 449.00, 'Available'),
(27, 'Thinking, Fast and Slow', 'Daniel Kahneman', 'Penguin Random House India', 'Non-Fiction', 649.00, 'Issued'),
(28, 'India After Gandhi', 'Ramachandra Guha', 'Pan Macmillan', 'Non-Fiction', 699.00, 'Available'),
(29, 'A Brief History of Time', 'Stephen Hawking', 'Penguin Random House India', 'Science', 699.00, 'Issued'),
(30, 'Cosmos', 'Carl Sagan', 'Penguin Random House India', 'Science', 599.00, 'Issued'),
(31, 'The Selfish Gene', 'Richard Dawkins', 'Oxford University Press', 'Science', 549.00, 'Available'),
(32, 'The Origin of Species', 'Charles Darwin', 'Oxford University Press', 'Science', 799.00, 'Available'),
(33, 'Silent Spring', 'Rachel Carson', 'Penguin Random House India', 'Science', 449.00, 'Issued'),
(34, 'The Elegant Universe', 'Brian Greene', 'W. W. Norton', 'Science', 499.00, 'Available'),
(35, 'Astrophysics for People in a Hurry', 'Neil deGrasse Tyson', 'W. W. Norton', 'Science', 649.00, 'Issued'),
(36, 'The Gene', 'Siddhartha Mukherjee', 'Penguin Random House India', 'Science', 599.00, 'Available'),
(37, 'Surely You''re Joking, Mr. Feynman', 'Richard P. Feynman', 'Penguin Random House India', 'Science', 500.00, 'Issued'),
(38, 'The Double Helix', 'James D. Watson', 'Penguin Random House India', 'Science', 449.00, 'Available'),
(39, 'Clean Code', 'Robert C. Martin', 'Pearson', 'Technology', 899.00, 'Available'),
(40, 'The Pragmatic Programmer', 'Andrew Hunt and David Thomas', 'Pearson', 'Technology', 999.00, 'Available'),
(41, 'Introduction to Algorithms', 'Thomas H. Cormen', 'MIT Press', 'Technology', 1199.00, 'Available'),
(42, 'Database System Concepts', 'Abraham Silberschatz', 'McGraw Hill', 'Technology', 1099.00, 'Available'),
(43, 'Learning SQL', 'Alan Beaulieu', 'O''Reilly Media', 'Technology', 649.00, 'Issued'),
(44, 'Python Crash Course', 'Eric Matthes', 'No Starch Press', 'Technology', 799.00, 'Issued'),
(45, 'Designing Data-Intensive Applications', 'Martin Kleppmann', 'O''Reilly Media', 'Technology', 1049.00, 'Issued'),
(46, 'Head First Java', 'Kathy Sierra and Bert Bates', 'O''Reilly Media', 'Technology', 749.00, 'Issued'),
(47, 'Computer Networking: A Top-Down Approach', 'James F. Kurose', 'Pearson', 'Technology', 899.00, 'Available'),
(48, 'Operating System Concepts', 'Abraham Silberschatz', 'Wiley', 'Technology', 999.00, 'Available'),
(49, 'Artificial Intelligence: A Modern Approach', 'Stuart Russell and Peter Norvig', 'Pearson', 'Technology', 1199.00, 'Available'),
(50, 'Storytelling with Data', 'Cole Nussbaumer Knaflic', 'Wiley', 'Technology', 849.00, 'Issued'),
(51, 'The Discovery of India', 'Jawaharlal Nehru', 'Penguin Random House India', 'History', 599.00, 'Issued'),
(52, 'A People''s History of the United States', 'Howard Zinn', 'HarperCollins', 'History', 449.00, 'Issued'),
(53, 'The Wonder That Was India', 'A. L. Basham', 'Picador', 'History', 699.00, 'Available'),
(54, 'Ancient India', 'R. S. Sharma', 'Orient BlackSwan', 'History', 549.00, 'Issued'),
(55, 'The Diary of a Young Girl', 'Anne Frank', 'Penguin Random House India', 'History', 299.00, 'Available'),
(56, 'SPQR', 'Mary Beard', 'Profile Books', 'History', 799.00, 'Issued'),
(57, 'The Guns of August', 'Barbara W. Tuchman', 'Penguin Random House India', 'History', 649.00, 'Issued'),
(58, 'Freedom at Midnight', 'Larry Collins and Dominique Lapierre', 'HarperCollins', 'History', 399.00, 'Issued'),
(59, 'An Era of Darkness', 'Shashi Tharoor', 'Aleph Book Company', 'History', 549.00, 'Available'),
(60, 'The Anarchy', 'William Dalrymple', 'Bloomsbury', 'History', 849.00, 'Available'),
(61, 'Wings of Fire', 'A. P. J. Abdul Kalam', 'Universities Press', 'Biography', 249.00, 'Available'),
(62, 'The Story of My Experiments with Truth', 'M. K. Gandhi', 'Navajivan Publishing House', 'Biography', 199.00, 'Available'),
(63, 'Steve Jobs', 'Walter Isaacson', 'Simon & Schuster', 'Biography', 549.00, 'Available'),
(64, 'Long Walk to Freedom', 'Nelson Mandela', 'Hachette India', 'Biography', 799.00, 'Available'),
(65, 'Becoming', 'Michelle Obama', 'Penguin Random House India', 'Biography', 699.00, 'Available'),
(66, 'Einstein: His Life and Universe', 'Walter Isaacson', 'Simon & Schuster', 'Biography', 899.00, 'Issued'),
(67, 'Playing It My Way', 'Sachin Tendulkar', 'Hachette India', 'Biography', 599.00, 'Available'),
(68, 'I Am Malala', 'Malala Yousafzai', 'Orion Publishing', 'Biography', 449.00, 'Available'),
(69, 'Harry Potter and the Philosopher''s Stone', 'J. K. Rowling', 'Bloomsbury', 'Fantasy', 499.00, 'Available'),
(70, 'The Hobbit', 'J. R. R. Tolkien', 'HarperCollins', 'Fantasy', 399.00, 'Available'),
(71, 'The Fellowship of the Ring', 'J. R. R. Tolkien', 'HarperCollins', 'Fantasy', 449.00, 'Available'),
(72, 'A Game of Thrones', 'George R. R. Martin', 'HarperCollins', 'Fantasy', 799.00, 'Available'),
(73, 'The Lion, the Witch and the Wardrobe', 'C. S. Lewis', 'HarperCollins', 'Fantasy', 349.00, 'Available'),
(74, 'Percy Jackson: The Lightning Thief', 'Rick Riordan', 'Penguin Random House India', 'Fantasy', 449.00, 'Available'),
(75, 'The Name of the Wind', 'Patrick Rothfuss', 'Orion Publishing', 'Fantasy', 499.00, 'Available'),
(76, 'American Gods', 'Neil Gaiman', 'Headline Publishing', 'Fantasy', 549.00, 'Available'),
(77, 'The Girl with the Dragon Tattoo', 'Stieg Larsson', 'Quercus', 'Mystery', 349.00, 'Available'),
(78, 'Gone Girl', 'Gillian Flynn', 'Orion Publishing', 'Mystery', 399.00, 'Available'),
(79, 'The Da Vinci Code', 'Dan Brown', 'Transworld Publishers', 'Mystery', 299.00, 'Available'),
(80, 'And Then There Were None', 'Agatha Christie', 'HarperCollins', 'Mystery', 299.00, 'Available'),
(81, 'The Hound of the Baskervilles', 'Arthur Conan Doyle', 'Penguin Random House India', 'Mystery', 249.00, 'Available'),
(82, 'Murder on the Orient Express', 'Agatha Christie', 'HarperCollins', 'Mystery', 249.00, 'Available'),
(83, 'The Silent Patient', 'Alex Michaelides', 'Orion Publishing', 'Mystery', 399.00, 'Available'),
(84, 'A Study in Scarlet', 'Arthur Conan Doyle', 'Penguin Random House India', 'Mystery', 199.00, 'Available'),
(85, 'Atomic Habits', 'James Clear', 'Penguin Random House India', 'Self-Help', 399.00, 'Available'),
(86, 'The 7 Habits of Highly Effective People', 'Stephen R. Covey', 'Simon & Schuster', 'Self-Help', 499.00, 'Available'),
(87, 'How to Win Friends and Influence People', 'Dale Carnegie', 'Simon & Schuster', 'Self-Help', 299.00, 'Issued'),
(88, 'Ikigai', 'Hector Garcia and Francesc Miralles', 'Penguin Random House India', 'Self-Help', 299.00, 'Available'),
(89, 'The Power of Now', 'Eckhart Tolle', 'Hachette India', 'Self-Help', 349.00, 'Available'),
(90, 'Mindset', 'Carol S. Dweck', 'Penguin Random House India', 'Self-Help', 299.00, 'Available'),
(91, 'Deep Work', 'Cal Newport', 'Hachette India', 'Self-Help', 349.00, 'Available'),
(92, 'You Can Win', 'Shiv Khera', 'Macmillan India', 'Self-Help', 249.00, 'Available'),
(93, 'Rich Dad Poor Dad', 'Robert T. Kiyosaki', 'Plata Publishing', 'Business', 349.00, 'Issued'),
(94, 'Zero to One', 'Peter Thiel', 'Penguin Random House India', 'Business', 299.00, 'Issued'),
(95, 'The Lean Startup', 'Eric Ries', 'Penguin Random House India', 'Business', 399.00, 'Available'),
(96, 'Good to Great', 'Jim Collins', 'HarperCollins', 'Business', 449.00, 'Available'),
(97, 'The Intelligent Investor', 'Benjamin Graham', 'HarperCollins', 'Business', 549.00, 'Issued'),
(98, 'Shoe Dog', 'Phil Knight', 'Simon & Schuster', 'Business', 599.00, 'Available'),
(99, 'Start with Why', 'Simon Sinek', 'Penguin Random House India', 'Business', 499.00, 'Available'),
(100, 'The Psychology of Money', 'Morgan Housel', 'Jaico Publishing', 'Business', 399.00, 'Available');
SELECT COUNT(*) AS books_inserted FROM Books;
-- EXPECTED OUTPUT: 1 row. books_inserted = 100

-- ---- 3.2 Members (100 rows)
INSERT INTO Members (member_id, name, email, phone, address, membership_date) VALUES
(1, 'Vivaan Choudhary', 'vivaan.choudhary2@yahoo.in', '8864076542', 'H.No 8-97-211, MVP Colony, Visakhapatnam, Andhra Pradesh 530017', '2023-10-05'),
(2, 'Bhavana Kumar', 'bhavana.kumar@yahoo.in', '9587144002', 'Flat 792, Gachibowli, Hyderabad, Telangana 500032', '2024-11-16'),
(3, 'Ishita Shetty', 'ishita.shetty@gmail.com', '9519182938', 'Plot 191, Miyapur, Hyderabad, Telangana 500049', '2025-01-29'),
(4, 'Shreya Reddy', 'shreya.reddy98@gmail.com', '9928374084', 'Flat 320, HSR Layout, Bengaluru, Karnataka 560102', '2025-07-01'),
(5, 'Harsha Choudhary', 'harsha.choudhary@gmail.com', '7285309315', 'Flat 722, Salt Lake, Kolkata, West Bengal 700091', '2024-03-13'),
(6, 'Sandeep Khan', 'sandeep.khan@gmail.com', '6934574388', 'Plot 155, Behala, Kolkata, West Bengal 700034', '2022-09-27'),
(7, 'Siddharth Chowdary', 'siddharth.chowdary@gmail.com', '8651290797', 'Flat 600, Banjara Hills, Hyderabad, Telangana 500034', '2023-05-30'),
(8, 'Ananya Yadav', 'ananya.yadav56@rediffmail.com', '7590811014', 'Flat 627, T. Nagar, Chennai, Tamil Nadu 600017', '2024-02-23'),
(9, 'Kiran Ahmed', 'kiran.ahmed@gmail.com', '9172896964', 'Flat 715, Madhapur, Hyderabad, Telangana 500081', '2025-09-19'),
(10, 'Rohan Singh', 'rohan.singh@gmail.com', '6065938520', 'Plot 60, Velachery, Chennai, Tamil Nadu 600042', '2022-01-14'),
(11, 'Ramesh Sharma', 'ramesh.sharma75@gmail.com', '6523911035', 'Plot 199, Bandra West, Mumbai, Maharashtra 400050', '2022-06-20'),
(12, 'Divya Tiwari', 'divya.tiwari42@outlook.com', '7913143629', 'Plot 191, Salt Lake, Kolkata, West Bengal 700091', '2025-04-27'),
(13, 'Neha Khan', 'neha.khan@gmail.com', '7556626971', 'Plot 15, Kukatpally, Hyderabad, Telangana 500072', '2026-06-25'),
(14, 'Aisha Chowdary', 'aisha.chowdary2@gmail.com', '6980645943', 'Plot 187, Rohini, Delhi, Delhi 110085', '2022-01-13'),
(15, 'Aarav Rao', 'aarav.rao@gmail.com', '7685792740', 'H.No 8-81-279, Madhapur, Hyderabad, Telangana 500081', '2022-02-19'),
(16, 'Pallavi Kapoor', 'pallavi.kapoor48@outlook.com', '8876553916', 'Flat 357, Saket, Delhi, Delhi 110017', '2024-12-14'),
(17, 'Sai Gupta', 'sai.gupta30@rediffmail.com', '7361261940', 'H.No 8-75-147, Banjara Hills, Hyderabad, Telangana 500034', '2023-04-05'),
(18, 'Manoj Yadav', 'manoj.yadav@yahoo.in', '7394165202', 'Flat 886, T. Nagar, Chennai, Tamil Nadu 600017', '2022-10-01'),
(19, 'Nisha Kapoor', 'nisha.kapoor@yahoo.in', '7081787423', 'H.No 9-8-267, Rohini, Delhi, Delhi 110085', '2023-02-03'),
(20, 'Yash Naidu', 'yash.naidu42@gmail.com', '8800691002', 'Plot 151, Powai, Mumbai, Maharashtra 400076', '2025-03-07'),
(21, 'Rekha Patel', 'rekha.patel@gmail.com', '6652607856', 'H.No 6-30-295, Behala, Kolkata, West Bengal 700034', '2023-12-26'),
(22, 'Anil Verma', 'anil.verma@gmail.com', '9642820004', 'Flat 594, Powai, Mumbai, Maharashtra 400076', '2024-06-12'),
(23, 'Shreya Menon', 'shreya.menon@yahoo.in', '8933690512', 'Flat 715, Ameerpet, Hyderabad, Telangana 500016', '2022-11-08'),
(24, 'Vamsi Gupta', 'vamsi.gupta13@gmail.com', '9904918993', 'Plot 92, Edappally, Kochi, Kerala 682024', '2025-06-19'),
(25, 'Madhavi Banerjee', 'madhavi.banerjee@outlook.com', '6053075176', 'Flat 643, Hanamkonda, Warangal, Telangana 506001', '2022-12-10'),
(26, 'Shreya Kulkarni', 'shreya.kulkarni@rediffmail.com', '7868758241', 'Plot 117, Andheri West, Mumbai, Maharashtra 400053', '2023-10-15'),
(27, 'Aditya Banerjee', 'aditya.banerjee88@outlook.com', '7375211711', 'Plot 116, Powai, Mumbai, Maharashtra 400076', '2023-03-08'),
(28, 'Manoj Prasad', 'manoj.prasad@outlook.com', '8023672797', 'H.No 5-24-279, Hadapsar, Pune, Maharashtra 411028', '2025-03-16'),
(29, 'Pooja Kumar', 'pooja.kumar75@gmail.com', '6759341687', 'Plot 80, Baner, Pune, Maharashtra 411045', '2024-07-01'),
(30, 'Kiran Pillai', 'kiran.pillai@yahoo.in', '8808920074', 'Plot 13, Rohini, Delhi, Delhi 110085', '2022-06-24'),
(31, 'Pallavi Gupta', 'pallavi.gupta@outlook.com', '8630005063', 'Plot 178, Bandra West, Mumbai, Maharashtra 400050', '2024-03-30'),
(32, 'Arjun Reddy', 'arjun.reddy65@gmail.com', '9401746436', 'Flat 870, Benz Circle, Vijayawada, Andhra Pradesh 520010', '2025-06-07'),
(33, 'Siddharth Varma', 'siddharth.varma@gmail.com', '7067281422', 'H.No 7-68-101, MVP Colony, Visakhapatnam, Andhra Pradesh 530017', '2022-08-03'),
(34, 'Rahul Hegde', 'rahul.hegde@gmail.com', '8700369815', 'H.No 5-92-119, Benz Circle, Vijayawada, Andhra Pradesh 520010', '2024-11-15'),
(35, 'Karthik Das', 'karthik.das@outlook.com', '9207637446', 'Plot 187, Jayanagar, Bengaluru, Karnataka 560011', '2025-09-26'),
(36, 'Pallavi Menon', 'pallavi.menon@gmail.com', '6224908004', 'H.No 7-19-130, Rohini, Delhi, Delhi 110085', '2023-05-22'),
(37, 'Rahul Banerjee', 'rahul.banerjee@gmail.com', '7994711933', 'Plot 60, Adyar, Chennai, Tamil Nadu 600020', '2022-11-04'),
(38, 'Srinivas Murthy', 'srinivas.murthy64@gmail.com', '7267526850', 'Plot 62, Malviya Nagar, Jaipur, Rajasthan 302017', '2026-03-07'),
(39, 'Yash Naik', 'yash.naik@rediffmail.com', '6430899043', 'Flat 243, Velachery, Chennai, Tamil Nadu 600042', '2023-05-31'),
(40, 'Kiran Bose', 'kiran.bose@gmail.com', '7951626458', 'H.No 7-68-65, Begumpet, Hyderabad, Telangana 500016', '2025-06-25'),
(41, 'Kavya Ahmed', 'kavya.ahmed@gmail.com', '7801785670', 'Plot 92, Velachery, Chennai, Tamil Nadu 600042', '2023-09-18'),
(42, 'Manoj Das', 'manoj.das47@gmail.com', '6977945712', 'Flat 342, Bandra West, Mumbai, Maharashtra 400050', '2022-05-31'),
(43, 'Priya Patel', 'priya.patel@outlook.com', '9154665860', 'Flat 723, Andheri West, Mumbai, Maharashtra 400053', '2023-01-10'),
(44, 'Sai Chowdary', 'sai.chowdary8@outlook.com', '7313573358', 'Plot 137, Hanamkonda, Warangal, Telangana 506001', '2022-12-01'),
(45, 'Zoya Agarwal', 'zoya.agarwal@outlook.com', '8456056810', 'Flat 444, Jayanagar, Bengaluru, Karnataka 560011', '2026-04-15'),
(46, 'Kavya Raju', 'kavya.raju42@outlook.com', '7523600144', 'Flat 546, Hadapsar, Pune, Maharashtra 411028', '2022-12-28'),
(47, 'Varun Choudhary', 'varun.choudhary11@gmail.com', '7658365949', 'Flat 245, Jubilee Hills, Hyderabad, Telangana 500033', '2023-08-22'),
(48, 'Rashmi Agarwal', 'rashmi.agarwal@gmail.com', '9750267675', 'Flat 300, Koramangala, Bengaluru, Karnataka 560034', '2024-02-26'),
(49, 'Tejaswini Pillai', 'tejaswini.pillai45@gmail.com', '7352564078', 'Plot 129, Jayanagar, Bengaluru, Karnataka 560011', '2022-05-27'),
(50, 'Ramesh Das', 'ramesh.das74@yahoo.in', '6134495856', 'H.No 3-85-121, Adyar, Chennai, Tamil Nadu 600020', '2022-03-09'),
(51, 'Charan Gupta', 'charan.gupta@gmail.com', '7190867751', 'Flat 773, Miyapur, Hyderabad, Telangana 500049', '2024-12-23'),
(52, 'Vikram Mehta', 'vikram.mehta@outlook.com', '9926935255', 'Flat 261, Malviya Nagar, Jaipur, Rajasthan 302017', '2026-01-09'),
(53, 'Priya Varma', 'priya.varma65@yahoo.in', '6194509696', 'H.No 5-49-217, Velachery, Chennai, Tamil Nadu 600042', '2024-08-02'),
(54, 'Mahesh Tiwari', 'mahesh.tiwari@gmail.com', '8173358331', 'Plot 44, Koramangala, Bengaluru, Karnataka 560034', '2025-05-24'),
(55, 'Arjun Yadav', 'arjun.yadav29@gmail.com', '8872206520', 'Plot 177, Jayanagar, Bengaluru, Karnataka 560011', '2022-06-08'),
(56, 'Nikhil Kumar', 'nikhil.kumar@rediffmail.com', '6715259781', 'Flat 259, Whitefield, Bengaluru, Karnataka 560066', '2025-05-26'),
(57, 'Tejaswini Tiwari', 'tejaswini.tiwari52@yahoo.in', '8384335911', 'Plot 53, Hadapsar, Pune, Maharashtra 411028', '2026-03-12'),
(58, 'Shreya Mehta', 'shreya.mehta@gmail.com', '9628478334', 'Plot 179, Rohini, Delhi, Delhi 110085', '2022-11-07'),
(59, 'Manoj Sharma', 'manoj.sharma24@gmail.com', '7344383085', 'H.No 4-71-92, Banjara Hills, Hyderabad, Telangana 500034', '2026-06-04'),
(60, 'Srinivas Rao', 'srinivas.rao@rediffmail.com', '8668011494', 'H.No 2-68-264, T. Nagar, Chennai, Tamil Nadu 600017', '2023-09-29'),
(61, 'Karthik Ahmed', 'karthik.ahmed60@yahoo.in', '6768884616', 'H.No 8-57-285, MVP Colony, Visakhapatnam, Andhra Pradesh 530017', '2022-09-01'),
(62, 'Aarav Menon', 'aarav.menon@gmail.com', '9096621114', 'Flat 247, Baner, Pune, Maharashtra 411045', '2023-07-24'),
(63, 'Anil Singh', 'anil.singh17@gmail.com', '7760452736', 'Flat 104, Rohini, Delhi, Delhi 110085', '2025-02-12'),
(64, 'Aarav Khan', 'aarav.khan@gmail.com', '7223828818', 'H.No 2-60-177, Kothrud, Pune, Maharashtra 411038', '2022-12-24'),
(65, 'Sunita Shetty', 'sunita.shetty@outlook.com', '6387787188', 'H.No 4-97-37, Hadapsar, Pune, Maharashtra 411028', '2025-10-24'),
(66, 'Krishna Raju', 'krishna.raju61@yahoo.in', '9575402752', 'H.No 8-85-134, Gachibowli, Hyderabad, Telangana 500032', '2022-03-07'),
(67, 'Priya Kulkarni', 'priya.kulkarni@gmail.com', '8122717229', 'Flat 319, Bandra West, Mumbai, Maharashtra 400050', '2026-02-21'),
(68, 'Vivaan Varma', 'vivaan.varma@gmail.com', '6663384400', 'H.No 1-26-119, Benz Circle, Vijayawada, Andhra Pradesh 520010', '2024-04-04'),
(69, 'Ananya Kumar', 'ananya.kumar38@gmail.com', '9497535662', 'Flat 595, Bandra West, Mumbai, Maharashtra 400050', '2025-09-02'),
(70, 'Krishna Rao', 'krishna.rao@yahoo.in', '8706645243', 'Plot 143, Baner, Pune, Maharashtra 411045', '2022-11-03'),
(71, 'Priya Gupta', 'priya.gupta@outlook.com', '7384205382', 'Flat 369, Miyapur, Hyderabad, Telangana 500049', '2022-01-09'),
(72, 'Rashmi Joshi', 'rashmi.joshi84@gmail.com', '9422734515', 'Plot 12, HSR Layout, Bengaluru, Karnataka 560102', '2025-01-18'),
(73, 'Imran Patel', 'imran.patel@gmail.com', '9037168812', 'Plot 149, Anna Nagar, Chennai, Tamil Nadu 600040', '2025-07-31'),
(74, 'Manoj Ahmed', 'manoj.ahmed@gmail.com', '8405736750', 'Flat 396, Navrangpura, Ahmedabad, Gujarat 380009', '2024-11-19'),
(75, 'Swathi Tiwari', 'swathi.tiwari45@gmail.com', '7930145943', 'Plot 25, Whitefield, Bengaluru, Karnataka 560066', '2025-05-20'),
(76, 'Anjali Shetty', 'anjali.shetty@outlook.com', '9591064833', 'Plot 125, Navrangpura, Ahmedabad, Gujarat 380009', '2024-03-19'),
(77, 'Venkat Yadav', 'venkat.yadav@yahoo.in', '7806258613', 'Plot 40, Ameerpet, Hyderabad, Telangana 500016', '2024-11-03'),
(78, 'Ravi Banerjee', 'ravi.banerjee@outlook.com', '7777653284', 'Flat 720, Navrangpura, Ahmedabad, Gujarat 380009', '2025-05-13'),
(79, 'Yash Agarwal', 'yash.agarwal@gmail.com', '9797622967', 'Flat 780, Hanamkonda, Warangal, Telangana 506001', '2025-04-18'),
(80, 'Sneha Sharma', 'sneha.sharma@gmail.com', '9357043652', 'H.No 7-93-165, Adyar, Chennai, Tamil Nadu 600020', '2023-09-09'),
(81, 'Arjun Khan', 'arjun.khan51@gmail.com', '7680938427', 'Flat 594, Bandra West, Mumbai, Maharashtra 400050', '2022-09-10'),
(82, 'Aditya Agarwal', 'aditya.agarwal67@yahoo.in', '9686473524', 'Flat 101, Miyapur, Hyderabad, Telangana 500049', '2023-04-18'),
(83, 'Sai Naik', 'sai.naik@gmail.com', '9402231197', 'Plot 146, HSR Layout, Bengaluru, Karnataka 560102', '2024-06-29'),
(84, 'Divya Hegde', 'divya.hegde@gmail.com', '7560401144', 'H.No 9-79-79, Powai, Mumbai, Maharashtra 400076', '2025-10-12'),
(85, 'Suresh Mehta', 'suresh.mehta@gmail.com', '6357645198', 'Flat 548, Rohini, Delhi, Delhi 110085', '2022-08-07'),
(86, 'Naveen Rao', 'naveen.rao@gmail.com', '7443723264', 'H.No 3-1-285, Velachery, Chennai, Tamil Nadu 600042', '2024-05-01'),
(87, 'Naveen Mishra', 'naveen.mishra@gmail.com', '7444635883', 'Flat 219, Indiranagar, Bengaluru, Karnataka 560038', '2023-04-10'),
(88, 'Suresh Iyer', 'suresh.iyer51@outlook.com', '6932983605', 'H.No 6-66-143, Adyar, Chennai, Tamil Nadu 600020', '2023-07-26'),
(89, 'Harsha Mishra', 'harsha.mishra39@rediffmail.com', '9230536678', 'Plot 58, Rohini, Delhi, Delhi 110085', '2023-07-26'),
(90, 'Sneha Yadav', 'sneha.yadav@gmail.com', '7945151902', 'Plot 131, Koramangala, Bengaluru, Karnataka 560034', '2024-06-28'),
(91, 'Charan Raju', 'charan.raju@gmail.com', '9662039682', 'H.No 9-24-222, MVP Colony, Visakhapatnam, Andhra Pradesh 530017', '2022-08-26'),
(92, 'Sai Mishra', 'sai.mishra@gmail.com', '6809988116', 'H.No 6-40-123, Behala, Kolkata, West Bengal 700034', '2025-09-27'),
(93, 'Varun Shetty', 'varun.shetty@gmail.com', '9133485676', 'Flat 637, Koramangala, Bengaluru, Karnataka 560034', '2023-12-07'),
(94, 'Madhavi Chowdary', 'madhavi.chowdary@gmail.com', '6616998427', 'Plot 99, Andheri West, Mumbai, Maharashtra 400053', '2024-08-24'),
(95, 'Pallavi Murthy', 'pallavi.murthy@yahoo.in', '8960917564', 'Flat 314, Jayanagar, Bengaluru, Karnataka 560011', '2023-06-17'),
(96, 'Bhavana Khan', 'bhavana.khan1@yahoo.in', '9211375756', 'Flat 301, Indiranagar, Bengaluru, Karnataka 560038', '2025-08-08'),
(97, 'Harini Rao', 'harini.rao@gmail.com', '8244923477', 'Flat 121, Adyar, Chennai, Tamil Nadu 600020', '2023-05-31'),
(98, 'Vikram Goud', 'vikram.goud@yahoo.in', '9698062198', 'Flat 785, Adyar, Chennai, Tamil Nadu 600020', '2024-12-12'),
(99, 'Pallavi Choudhary', 'pallavi.choudhary65@gmail.com', '6014047207', 'Plot 160, Jayanagar, Bengaluru, Karnataka 560011', '2024-10-22'),
(100, 'Tarun Gupta', 'tarun.gupta32@gmail.com', '6460785106', 'Plot 32, Whitefield, Bengaluru, Karnataka 560066', '2022-08-30');
SELECT COUNT(*) AS members_inserted FROM Members;
-- EXPECTED OUTPUT: 1 row. members_inserted = 100

-- ---- 3.3 Librarians (10 rows)
INSERT INTO Librarians (librarian_id, name, phone, joining_date) VALUES
(1, 'Sunitha Rao', '9848012345', '2015-06-15'),
(2, 'Ramesh Kumar', '9440123456', '2016-03-01'),
(3, 'Lakshmi Narayan', '9701234567', '2017-08-21'),
(4, 'Imran Sheikh', '9848123456', '2018-01-10'),
(5, 'Padma Reddy', '9963123456', '2018-11-05'),
(6, 'Vijay Menon', '9246123456', '2019-07-18'),
(7, 'Anitha Joseph', '9177123456', '2020-02-24'),
(8, 'Suresh Babu', '9396123456', '2021-09-01'),
(9, 'Farah Khan', '9505123456', '2022-04-12'),
(10, 'Deepa Nair', '9618123456', '2023-01-09');
SELECT COUNT(*) AS librarians_inserted FROM Librarians;
-- EXPECTED OUTPUT: 1 row. librarians_inserted = 10

-- ---- 3.4 Borrow_Records (200 rows: 170 Returned, 30 Borrowed)
-- 'Borrowed' rows have return_date NULL and belong to the 30 'Issued' books.
INSERT INTO Borrow_Records (borrow_id, member_id, book_id, librarian_id, borrow_date, return_date, status) VALUES
(1, 42, 49, 9, '2025-01-05', '2025-01-20', 'Returned'),
(2, 95, 18, 2, '2025-01-08', '2025-01-31', 'Returned'),
(3, 47, 12, 10, '2025-01-16', '2025-01-22', 'Returned'),
(4, 47, 64, 2, '2025-01-23', '2025-02-07', 'Returned'),
(5, 72, 65, 3, '2025-01-23', '2025-02-26', 'Returned'),
(6, 85, 12, 5, '2025-01-24', '2025-02-10', 'Returned'),
(7, 5, 47, 2, '2025-02-03', '2025-03-01', 'Returned'),
(8, 10, 74, 4, '2025-02-07', '2025-03-16', 'Returned'),
(9, 77, 75, 4, '2025-02-07', '2025-02-15', 'Returned'),
(10, 1, 19, 7, '2025-02-08', '2025-02-17', 'Returned'),
(11, 41, 49, 3, '2025-02-12', '2025-02-16', 'Returned'),
(12, 34, 76, 3, '2025-02-16', '2025-03-21', 'Returned'),
(13, 58, 80, 2, '2025-02-17', '2025-03-16', 'Returned'),
(14, 95, 24, 9, '2025-02-22', '2025-02-28', 'Returned'),
(15, 10, 92, 2, '2025-03-02', '2025-04-03', 'Returned'),
(16, 29, 7, 4, '2025-03-12', '2025-04-12', 'Returned'),
(17, 26, 81, 7, '2025-03-14', '2025-04-14', 'Returned'),
(18, 71, 88, 4, '2025-03-21', '2025-04-26', 'Returned'),
(19, 68, 19, 3, '2025-03-22', '2025-03-28', 'Returned'),
(20, 82, 21, 9, '2025-03-25', '2025-04-04', 'Returned'),
(21, 91, 1, 10, '2025-03-28', '2025-05-01', 'Returned'),
(22, 93, 72, 7, '2025-04-03', '2025-04-20', 'Returned'),
(23, 1, 42, 8, '2025-04-04', '2025-04-22', 'Returned'),
(24, 66, 82, 6, '2025-04-07', '2025-05-08', 'Returned'),
(25, 93, 99, 10, '2025-04-10', '2025-05-15', 'Returned'),
(26, 71, 7, 7, '2025-04-20', '2025-05-04', 'Returned'),
(27, 64, 2, 7, '2025-04-22', '2025-04-27', 'Returned'),
(28, 18, 60, 7, '2025-04-23', '2025-05-08', 'Returned'),
(29, 99, 74, 10, '2025-04-24', '2025-05-29', 'Returned'),
(30, 99, 80, 10, '2025-04-26', '2025-05-20', 'Returned'),
(31, 82, 16, 5, '2025-04-27', '2025-05-26', 'Returned'),
(32, 18, 2, 3, '2025-05-05', '2025-05-30', 'Returned'),
(33, 80, 19, 2, '2025-05-05', '2025-06-05', 'Returned'),
(34, 51, 85, 6, '2025-05-05', '2025-06-08', 'Returned'),
(35, 46, 82, 7, '2025-05-12', '2025-06-13', 'Returned'),
(36, 33, 62, 6, '2025-05-13', '2025-06-10', 'Returned'),
(37, 16, 21, 6, '2025-05-16', '2025-05-21', 'Returned'),
(38, 64, 90, 4, '2025-05-16', '2025-05-30', 'Returned'),
(39, 68, 89, 3, '2025-05-18', '2025-05-30', 'Returned'),
(40, 79, 92, 9, '2025-05-20', '2025-06-11', 'Returned'),
(41, 74, 70, 1, '2025-05-21', '2025-06-08', 'Returned'),
(42, 87, 91, 2, '2025-05-24', '2025-06-18', 'Returned'),
(43, 79, 40, 9, '2025-05-26', '2025-06-06', 'Returned'),
(44, 100, 100, 4, '2025-05-26', '2025-06-23', 'Returned'),
(45, 60, 88, 7, '2025-06-03', '2025-06-14', 'Returned'),
(46, 21, 90, 9, '2025-06-04', '2025-07-09', 'Returned'),
(47, 39, 99, 5, '2025-06-05', '2025-07-01', 'Returned'),
(48, 62, 53, 4, '2025-06-12', '2025-06-24', 'Returned'),
(49, 30, 38, 3, '2025-06-13', '2025-07-10', 'Returned'),
(50, 100, 48, 4, '2025-06-13', '2025-07-17', 'Returned'),
(51, 36, 67, 10, '2025-06-14', '2025-07-09', 'Returned'),
(52, 81, 9, 3, '2025-06-15', '2025-07-01', 'Returned'),
(53, 86, 14, 10, '2025-06-15', '2025-07-12', 'Returned'),
(54, 95, 72, 7, '2025-06-16', '2025-07-20', 'Returned'),
(55, 71, 1, 1, '2025-06-19', '2025-07-27', 'Returned'),
(56, 66, 7, 4, '2025-06-20', '2025-07-21', 'Returned'),
(57, 81, 83, 3, '2025-06-20', '2025-07-07', 'Returned'),
(58, 93, 78, 7, '2025-06-21', '2025-07-04', 'Returned'),
(59, 61, 5, 1, '2025-07-01', '2025-08-06', 'Returned'),
(60, 26, 9, 3, '2025-07-03', '2025-07-29', 'Returned'),
(61, 49, 26, 1, '2025-07-10', '2025-08-06', 'Returned'),
(62, 90, 91, 2, '2025-07-10', '2025-07-30', 'Returned'),
(63, 29, 32, 8, '2025-07-12', '2025-07-25', 'Returned'),
(64, 7, 19, 10, '2025-07-13', '2025-07-18', 'Returned'),
(65, 4, 28, 2, '2025-07-13', '2025-07-21', 'Returned'),
(66, 87, 40, 10, '2025-07-15', '2025-08-15', 'Returned'),
(67, 54, 16, 5, '2025-07-16', '2025-08-07', 'Returned'),
(68, 16, 84, 1, '2025-07-17', '2025-07-26', 'Returned'),
(69, 43, 85, 3, '2025-07-17', '2025-07-22', 'Returned'),
(70, 53, 10, 7, '2025-07-20', '2025-08-27', 'Returned'),
(71, 19, 79, 3, '2025-07-20', '2025-08-01', 'Returned'),
(72, 51, 7, 1, '2025-07-23', '2025-07-30', 'Returned'),
(73, 68, 2, 1, '2025-07-26', '2025-08-16', 'Returned'),
(74, 17, 83, 4, '2025-07-28', '2025-08-22', 'Returned'),
(75, 20, 84, 7, '2025-08-01', '2025-08-08', 'Returned'),
(76, 33, 69, 2, '2025-08-02', '2025-09-03', 'Returned'),
(77, 73, 78, 6, '2025-08-02', '2025-08-30', 'Returned'),
(78, 68, 88, 10, '2025-08-02', '2025-09-09', 'Returned'),
(79, 42, 39, 4, '2025-08-04', '2025-08-21', 'Returned'),
(80, 87, 99, 4, '2025-08-04', '2025-09-10', 'Returned'),
(81, 27, 15, 9, '2025-08-05', '2025-08-23', 'Returned'),
(82, 88, 4, 3, '2025-08-06', '2025-09-13', 'Returned'),
(83, 95, 95, 9, '2025-08-06', '2025-08-27', 'Returned'),
(84, 76, 96, 4, '2025-08-08', '2025-09-13', 'Returned'),
(85, 40, 14, 2, '2025-08-14', '2025-08-28', 'Returned'),
(86, 51, 36, 6, '2025-08-19', '2025-09-11', 'Returned'),
(87, 40, 61, 2, '2025-08-19', '2025-08-26', 'Returned'),
(88, 8, 53, 1, '2025-08-23', '2025-09-01', 'Returned'),
(89, 97, 59, 5, '2025-08-24', '2025-09-08', 'Returned'),
(90, 87, 72, 10, '2025-08-30', '2025-09-06', 'Returned'),
(91, 98, 85, 4, '2025-08-31', '2025-10-02', 'Returned'),
(92, 91, 28, 2, '2025-09-01', '2025-10-05', 'Returned'),
(93, 18, 32, 6, '2025-09-06', '2025-09-11', 'Returned'),
(94, 63, 63, 9, '2025-09-06', '2025-10-12', 'Returned'),
(95, 32, 91, 3, '2025-09-09', '2025-09-29', 'Returned'),
(96, 73, 79, 9, '2025-09-10', '2025-09-17', 'Returned'),
(97, 3, 72, 2, '2025-09-13', '2025-10-11', 'Returned'),
(98, 4, 19, 4, '2025-09-16', '2025-10-09', 'Returned'),
(99, 19, 78, 2, '2025-09-16', '2025-10-19', 'Returned'),
(100, 18, 40, 6, '2025-09-18', '2025-10-13', 'Returned'),
(101, 12, 36, 7, '2025-09-21', '2025-10-13', 'Returned'),
(102, 28, 9, 1, '2025-09-22', '2025-10-18', 'Returned'),
(103, 18, 96, 4, '2025-09-22', '2025-10-19', 'Returned'),
(104, 58, 7, 4, '2025-09-23', '2025-10-14', 'Returned'),
(105, 48, 61, 6, '2025-09-24', '2025-10-21', 'Returned'),
(106, 69, 15, 7, '2025-09-29', '2025-10-22', 'Returned'),
(107, 76, 2, 2, '2025-09-30', '2025-10-05', 'Returned'),
(108, 63, 69, 3, '2025-10-01', '2025-10-07', 'Returned'),
(109, 8, 39, 6, '2025-10-04', '2025-10-19', 'Returned'),
(110, 7, 95, 9, '2025-10-05', '2025-10-18', 'Returned'),
(111, 16, 85, 6, '2025-10-09', '2025-10-26', 'Returned'),
(112, 9, 40, 3, '2025-10-16', '2025-11-15', 'Returned'),
(113, 95, 10, 9, '2025-10-22', '2025-11-01', 'Returned'),
(114, 36, 32, 4, '2025-10-22', '2025-11-08', 'Returned'),
(115, 36, 14, 6, '2025-10-26', '2025-11-14', 'Returned'),
(116, 48, 7, 4, '2025-10-28', '2025-11-07', 'Returned'),
(117, 21, 78, 8, '2025-10-29', '2025-12-02', 'Returned'),
(118, 97, 85, 9, '2025-10-30', '2025-11-30', 'Returned'),
(119, 95, 15, 2, '2025-11-04', '2025-11-18', 'Returned'),
(120, 66, 9, 9, '2025-11-13', '2025-12-10', 'Returned'),
(121, 75, 95, 7, '2025-11-17', '2025-11-30', 'Returned'),
(122, 15, 69, 9, '2025-11-22', '2025-12-06', 'Returned'),
(123, 4, 40, 9, '2025-12-02', '2025-12-15', 'Returned'),
(124, 20, 39, 3, '2025-12-06', '2025-12-22', 'Returned'),
(125, 31, 85, 10, '2025-12-24', '2026-01-31', 'Returned'),
(126, 29, 69, 2, '2026-01-14', '2026-02-18', 'Returned'),
(127, 64, 45, 1, '2026-01-15', '2026-02-04', 'Returned'),
(128, 97, 95, 4, '2026-01-18', '2026-02-12', 'Returned'),
(129, 8, 40, 5, '2026-01-20', '2026-02-16', 'Returned'),
(130, 68, 39, 10, '2026-01-23', '2026-03-02', 'Returned'),
(131, 76, 78, 10, '2026-01-29', '2026-02-07', 'Returned'),
(132, 86, 87, 6, '2026-02-02', '2026-03-07', 'Returned'),
(133, 23, 85, 3, '2026-02-16', '2026-03-08', 'Returned'),
(134, 52, 69, 4, '2026-02-22', '2026-03-06', 'Returned'),
(135, 33, 43, 6, '2026-02-23', '2026-03-21', 'Returned'),
(136, 92, 94, 7, '2026-03-06', '2026-03-10', 'Returned'),
(137, 54, 95, 1, '2026-03-06', '2026-04-11', 'Returned'),
(138, 9, 45, 2, '2026-03-09', '2026-04-10', 'Returned'),
(139, 57, 40, 10, '2026-03-17', '2026-04-20', 'Returned'),
(140, 58, 39, 2, '2026-04-05', '2026-04-17', 'Returned'),
(141, 98, 23, 7, '2026-04-07', '2026-05-07', 'Returned'),
(142, 40, 87, 6, '2026-04-10', '2026-04-27', 'Returned'),
(143, 45, 94, 10, '2026-04-24', '2026-05-02', 'Returned'),
(144, 58, 43, 6, '2026-05-01', '2026-06-08', 'Returned'),
(145, 22, 45, 7, '2026-05-08', '2026-05-20', 'Returned'),
(146, 71, 94, 7, '2026-05-10', '2026-05-31', 'Returned'),
(147, 38, 23, 1, '2026-05-15', NULL, 'Borrowed'),
(148, 83, 87, 6, '2026-05-16', '2026-06-14', 'Returned'),
(149, 96, 95, 9, '2026-05-16', '2026-06-21', 'Returned'),
(150, 2, 45, 2, '2026-06-04', '2026-07-11', 'Returned'),
(151, 61, 43, 7, '2026-06-14', '2026-07-05', 'Returned'),
(152, 83, 35, 1, '2026-07-06', NULL, 'Borrowed'),
(153, 44, 50, 10, '2026-07-07', '2026-07-23', 'Returned'),
(154, 80, 17, 4, '2026-07-08', '2026-07-20', 'Returned'),
(155, 60, 87, 9, '2026-07-14', '2026-08-21', 'Returned'),
(156, 75, 27, 3, '2026-07-18', '2026-07-22', 'Returned'),
(157, 97, 37, 1, '2026-07-22', '2026-08-20', 'Returned'),
(158, 58, 45, 3, '2026-07-24', '2026-08-18', 'Returned'),
(159, 65, 94, 5, '2026-07-25', '2026-08-15', 'Returned'),
(160, 13, 27, 6, '2026-07-31', '2026-08-23', 'Returned'),
(161, 68, 17, 7, '2026-08-12', NULL, 'Borrowed'),
(162, 84, 66, 10, '2026-08-14', '2026-08-29', 'Returned'),
(163, 14, 50, 6, '2026-08-17', '2026-09-18', 'Returned'),
(164, 71, 43, 1, '2026-08-28', '2026-09-26', 'Returned'),
(165, 98, 37, 2, '2026-08-31', '2026-09-26', 'Returned'),
(166, 5, 66, 1, '2026-09-02', '2026-09-18', 'Returned'),
(167, 46, 29, 3, '2026-09-08', '2026-09-23', 'Returned'),
(168, 54, 94, 10, '2026-09-08', '2026-10-07', 'Returned'),
(169, 67, 13, 4, '2026-09-10', NULL, 'Borrowed'),
(170, 33, 44, 4, '2026-09-11', NULL, 'Borrowed'),
(171, 9, 51, 4, '2026-09-15', NULL, 'Borrowed'),
(172, 50, 56, 3, '2026-09-16', '2026-10-03', 'Returned'),
(173, 88, 87, 1, '2026-09-16', NULL, 'Borrowed'),
(174, 4, 27, 9, '2026-09-17', NULL, 'Borrowed'),
(175, 65, 45, 9, '2026-09-19', '2026-10-18', 'Returned'),
(176, 30, 25, 2, '2026-09-21', NULL, 'Borrowed'),
(177, 94, 6, 2, '2026-09-23', '2026-10-05', 'Returned'),
(178, 4, 46, 5, '2026-09-25', '2026-10-11', 'Returned'),
(179, 33, 11, 5, '2026-10-04', NULL, 'Borrowed'),
(180, 40, 30, 1, '2026-10-12', '2026-10-19', 'Returned'),
(181, 89, 43, 6, '2026-10-14', NULL, 'Borrowed'),
(182, 98, 50, 7, '2026-10-15', NULL, 'Borrowed'),
(183, 9, 94, 7, '2026-10-15', NULL, 'Borrowed'),
(184, 95, 22, 4, '2026-10-17', NULL, 'Borrowed'),
(185, 59, 46, 9, '2026-10-17', NULL, 'Borrowed'),
(186, 23, 66, 4, '2026-10-19', NULL, 'Borrowed'),
(187, 9, 6, 2, '2026-10-20', NULL, 'Borrowed'),
(188, 6, 37, 7, '2026-10-21', NULL, 'Borrowed'),
(189, 89, 57, 9, '2026-10-21', NULL, 'Borrowed'),
(190, 87, 29, 4, '2026-10-22', NULL, 'Borrowed'),
(191, 85, 93, 4, '2026-10-23', NULL, 'Borrowed'),
(192, 58, 58, 1, '2026-10-26', NULL, 'Borrowed'),
(193, 4, 3, 4, '2026-10-28', NULL, 'Borrowed'),
(194, 31, 52, 3, '2026-10-29', NULL, 'Borrowed'),
(195, 54, 30, 10, '2026-11-03', NULL, 'Borrowed'),
(196, 63, 45, 2, '2026-11-03', NULL, 'Borrowed'),
(197, 14, 33, 6, '2026-11-04', NULL, 'Borrowed'),
(198, 68, 56, 9, '2026-11-04', NULL, 'Borrowed'),
(199, 35, 54, 6, '2026-11-05', NULL, 'Borrowed'),
(200, 31, 97, 2, '2026-11-07', NULL, 'Borrowed');
SELECT COUNT(*) AS borrow_records_inserted FROM Borrow_Records;
-- EXPECTED OUTPUT: 1 row. borrow_records_inserted = 200

-- ---- 3.5 Reservations (60 rows)
INSERT INTO Reservations (reservation_id, member_id, book_id, reservation_date) VALUES
(1, 97, 16, '2025-04-03'),
(2, 10, 74, '2025-05-05'),
(3, 68, 1, '2025-05-10'),
(4, 39, 23, '2025-05-18'),
(5, 32, 22, '2025-06-25'),
(6, 19, 40, '2025-07-06'),
(7, 4, 18, '2025-07-26'),
(8, 75, 57, '2025-08-26'),
(9, 54, 49, '2025-09-01'),
(10, 20, 20, '2025-09-20'),
(11, 19, 64, '2025-10-09'),
(12, 65, 65, '2025-11-19'),
(13, 95, 13, '2025-11-21'),
(14, 35, 82, '2026-01-06'),
(15, 95, 76, '2026-02-13'),
(16, 80, 96, '2026-03-21'),
(17, 96, 36, '2026-03-25'),
(18, 10, 20, '2026-04-06'),
(19, 74, 91, '2026-04-12'),
(20, 82, 16, '2026-04-30'),
(21, 16, 98, '2026-05-06'),
(22, 15, 46, '2026-05-08'),
(23, 39, 18, '2026-05-14'),
(24, 7, 89, '2026-05-27'),
(25, 37, 23, '2026-06-07'),
(26, 95, 68, '2026-06-16'),
(27, 92, 1, '2026-07-18'),
(28, 10, 78, '2026-08-10'),
(29, 73, 85, '2026-08-11'),
(30, 14, 4, '2026-08-14'),
(31, 12, 17, '2026-08-31'),
(32, 72, 23, '2026-09-10'),
(33, 24, 51, '2026-09-28'),
(34, 87, 35, '2026-10-02'),
(35, 25, 25, '2026-10-03'),
(36, 30, 11, '2026-10-10'),
(37, 75, 13, '2026-10-13'),
(38, 3, 94, '2026-10-21'),
(39, 29, 17, '2026-10-21'),
(40, 55, 13, '2026-10-22'),
(41, 14, 16, '2026-10-30'),
(42, 32, 93, '2026-10-31'),
(43, 22, 87, '2026-11-01'),
(44, 79, 46, '2026-11-01'),
(45, 15, 58, '2026-11-04'),
(46, 20, 29, '2026-11-04'),
(47, 4, 25, '2026-11-05'),
(48, 52, 33, '2026-11-05'),
(49, 24, 56, '2026-11-06'),
(50, 38, 57, '2026-11-06'),
(51, 67, 44, '2026-11-07'),
(52, 83, 56, '2026-11-07'),
(53, 11, 97, '2026-11-08'),
(54, 11, 50, '2026-11-09'),
(55, 35, 30, '2026-11-09'),
(56, 39, 3, '2026-11-09'),
(57, 38, 30, '2026-11-10'),
(58, 45, 45, '2026-11-10'),
(59, 54, 57, '2026-11-11'),
(60, 97, 58, '2026-11-12');
SELECT COUNT(*) AS reservations_inserted FROM Reservations;
-- EXPECTED OUTPUT: 1 row. reservations_inserted = 60

-- ============================================================================
-- PART 4 - DATA VALIDATION (run right after loading the data)
-- ============================================================================

-- ---- 4A Row counts in every table
SELECT 'Books' AS table_name, COUNT(*) AS row_count FROM Books
UNION ALL SELECT 'Members', COUNT(*) FROM Members
UNION ALL SELECT 'Librarians', COUNT(*) FROM Librarians
UNION ALL SELECT 'Borrow_Records', COUNT(*) FROM Borrow_Records
UNION ALL SELECT 'Reservations', COUNT(*) FROM Reservations;
-- EXPECTED OUTPUT: 5 rows
--     Books | 100
--     Members | 100
--     Librarians | 10
--     Borrow_Records | 200
--     Reservations | 60

-- ---- 4B Primary key uniqueness, duplicate emails and orphan foreign keys (every violations value must be 0)
SELECT 'Books: duplicate book_id' AS check_name, (SELECT COUNT(*) - COUNT(DISTINCT book_id) FROM Books) AS violations
UNION ALL SELECT 'Members: duplicate member_id', (SELECT COUNT(*) - COUNT(DISTINCT member_id) FROM Members)
UNION ALL SELECT 'Librarians: duplicate librarian_id', (SELECT COUNT(*) - COUNT(DISTINCT librarian_id) FROM Librarians)
UNION ALL SELECT 'Borrow_Records: duplicate borrow_id', (SELECT COUNT(*) - COUNT(DISTINCT borrow_id) FROM Borrow_Records)
UNION ALL SELECT 'Reservations: duplicate reservation_id', (SELECT COUNT(*) - COUNT(DISTINCT reservation_id) FROM Reservations)
UNION ALL SELECT 'Members: duplicate email', (SELECT COUNT(email) - COUNT(DISTINCT email) FROM Members)
UNION ALL SELECT 'Borrow_Records: member_id not in Members', (SELECT COUNT(*) FROM Borrow_Records br LEFT JOIN Members m ON m.member_id = br.member_id WHERE m.member_id IS NULL)
UNION ALL SELECT 'Borrow_Records: book_id not in Books', (SELECT COUNT(*) FROM Borrow_Records br LEFT JOIN Books b ON b.book_id = br.book_id WHERE b.book_id IS NULL)
UNION ALL SELECT 'Borrow_Records: librarian_id not in Librarians', (SELECT COUNT(*) FROM Borrow_Records br LEFT JOIN Librarians l ON l.librarian_id = br.librarian_id WHERE l.librarian_id IS NULL)
UNION ALL SELECT 'Reservations: member_id not in Members', (SELECT COUNT(*) FROM Reservations r LEFT JOIN Members m ON m.member_id = r.member_id WHERE m.member_id IS NULL)
UNION ALL SELECT 'Reservations: book_id not in Books', (SELECT COUNT(*) FROM Reservations r LEFT JOIN Books b ON b.book_id = r.book_id WHERE b.book_id IS NULL);
-- EXPECTED OUTPUT: 11 rows, every violations value = 0

-- ---- 4C NULL values in important columns (every violations value must be 0)
-- return_date is allowed to be NULL (only for 'Borrowed' rows) and is checked in 4D.
SELECT 'Books: NULL in any column' AS check_name, (SELECT COUNT(*) FROM Books WHERE title IS NULL OR author IS NULL OR publisher IS NULL OR category IS NULL OR price IS NULL OR availability_status IS NULL) AS violations
UNION ALL SELECT 'Members: NULL in any column', (SELECT COUNT(*) FROM Members WHERE name IS NULL OR email IS NULL OR phone IS NULL OR address IS NULL OR membership_date IS NULL)
UNION ALL SELECT 'Librarians: NULL in any column', (SELECT COUNT(*) FROM Librarians WHERE name IS NULL OR phone IS NULL OR joining_date IS NULL)
UNION ALL SELECT 'Borrow_Records: NULL FK / borrow_date / status', (SELECT COUNT(*) FROM Borrow_Records WHERE member_id IS NULL OR book_id IS NULL OR librarian_id IS NULL OR borrow_date IS NULL OR status IS NULL)
UNION ALL SELECT 'Reservations: NULL in any column', (SELECT COUNT(*) FROM Reservations WHERE member_id IS NULL OR book_id IS NULL OR reservation_date IS NULL);
-- EXPECTED OUTPUT: 5 rows, every violations value = 0

-- ---- 4D Status and inventory consistency (every violations value must be 0)
-- 'Available vs issued': every Issued book must have exactly one open loan and vice versa.
SELECT 'Books: status not ''Available'' or ''Issued''' AS check_name, (SELECT COUNT(*) FROM Books WHERE availability_status NOT IN ('Available', 'Issued')) AS violations
UNION ALL SELECT 'Borrow_Records: status not ''Borrowed'' or ''Returned''', (SELECT COUNT(*) FROM Borrow_Records WHERE status NOT IN ('Borrowed', 'Returned'))
UNION ALL SELECT 'Issued books without a Borrowed record', (SELECT COUNT(*) FROM Books b WHERE b.availability_status = 'Issued' AND NOT EXISTS (SELECT 1 FROM Borrow_Records br WHERE br.book_id = b.book_id AND br.status = 'Borrowed'))
UNION ALL SELECT 'Books with a Borrowed record but not Issued', (SELECT COUNT(*) FROM Books b WHERE b.availability_status <> 'Issued' AND EXISTS (SELECT 1 FROM Borrow_Records br WHERE br.book_id = b.book_id AND br.status = 'Borrowed'))
UNION ALL SELECT 'Books with more than one open (Borrowed) record', (SELECT COUNT(*) FROM (SELECT book_id FROM Borrow_Records WHERE status = 'Borrowed' GROUP BY book_id HAVING COUNT(*) > 1) t)
UNION ALL SELECT 'Returned records with NULL return_date', (SELECT COUNT(*) FROM Borrow_Records WHERE status = 'Returned' AND return_date IS NULL)
UNION ALL SELECT 'Borrowed records with a return_date', (SELECT COUNT(*) FROM Borrow_Records WHERE status = 'Borrowed' AND return_date IS NOT NULL)
UNION ALL SELECT 'Overlapping loans of the same book', (SELECT COUNT(*) FROM Borrow_Records a JOIN Borrow_Records b ON a.book_id = b.book_id AND a.borrow_id < b.borrow_id AND a.borrow_date <= COALESCE(b.return_date, '9999-12-31') AND b.borrow_date <= COALESCE(a.return_date, '9999-12-31'))
UNION ALL SELECT 'Same member borrowing the same book twice (sample-data design)', (SELECT COUNT(*) FROM (SELECT member_id, book_id FROM Borrow_Records GROUP BY member_id, book_id HAVING COUNT(*) > 1) t)
UNION ALL SELECT 'Same member reserving the same book twice', (SELECT COUNT(*) FROM (SELECT member_id, book_id FROM Reservations GROUP BY member_id, book_id HAVING COUNT(*) > 1) t);
-- EXPECTED OUTPUT: 10 rows, every violations value = 0

-- ---- 4E Date logic (every violations value must be 0)
SELECT 'return_date earlier than borrow_date' AS check_name, (SELECT COUNT(*) FROM Borrow_Records WHERE return_date < borrow_date) AS violations
UNION ALL SELECT 'borrow_date before the member''s membership_date', (SELECT COUNT(*) FROM Borrow_Records br JOIN Members m ON m.member_id = br.member_id WHERE br.borrow_date < m.membership_date)
UNION ALL SELECT 'borrow_date before the librarian''s joining_date', (SELECT COUNT(*) FROM Borrow_Records br JOIN Librarians l ON l.librarian_id = br.librarian_id WHERE br.borrow_date < l.joining_date)
UNION ALL SELECT 'reservation_date before the member''s membership_date', (SELECT COUNT(*) FROM Reservations r JOIN Members m ON m.member_id = r.member_id WHERE r.reservation_date < m.membership_date)
UNION ALL SELECT 'Dates after the data cut-off 2026-11-13', (SELECT COUNT(*) FROM Borrow_Records WHERE borrow_date > '2026-11-13' OR return_date > '2026-11-13')
UNION ALL SELECT 'Members reserving a book they currently have borrowed', (SELECT COUNT(*) FROM Reservations r JOIN Borrow_Records br ON br.member_id = r.member_id AND br.book_id = r.book_id AND br.status = 'Borrowed');
-- EXPECTED OUTPUT: 6 rows, every violations value = 0

-- ---- 4F Status distribution
SELECT 'Books' AS source_table, availability_status AS status_value, COUNT(*) AS row_count FROM Books GROUP BY availability_status
UNION ALL
SELECT 'Borrow_Records', status, COUNT(*) FROM Borrow_Records GROUP BY status
ORDER BY 1, 2;
-- EXPECTED OUTPUT: 4 rows. Columns: source_table, status_value, row_count
--     Books | Available | 70
--     Books | Issued | 30
--     Borrow_Records | Borrowed | 30
--     Borrow_Records | Returned | 170

-- ---- 4G Inventory reconciliation: Issued books versus open loans
SELECT
  (SELECT COUNT(*) FROM Books WHERE availability_status = 'Issued') AS issued_books,
  (SELECT COUNT(DISTINCT book_id) FROM Borrow_Records WHERE status = 'Borrowed') AS books_with_open_loan,
  (SELECT COUNT(*) FROM Borrow_Records WHERE status = 'Borrowed') AS open_loans;
-- EXPECTED OUTPUT: 1 row. Columns: issued_books, books_with_open_loan, open_loans
--     30 | 30 | 30

-- ============================================================================
-- PART 5 - BASIC SQL QUERIES
-- ============================================================================

-- ---- BASIC QUERY 1 - Insert sample data into all tables
-- Implemented in PART 3. Verification of the inserted rows:
SELECT 'Books' AS table_name, COUNT(*) AS rows_inserted FROM Books
UNION ALL SELECT 'Members', COUNT(*) FROM Members
UNION ALL SELECT 'Librarians', COUNT(*) FROM Librarians
UNION ALL SELECT 'Borrow_Records', COUNT(*) FROM Borrow_Records
UNION ALL SELECT 'Reservations', COUNT(*) FROM Reservations;
-- EXPECTED OUTPUT: 5 rows: 100, 100, 10, 200, 60

-- ---- BASIC QUERY 2 - Display books with price greater than 500
-- Strictly greater than 500: the 3 books priced exactly 500.00 are NOT included.
SELECT book_id, title, author, category, price
FROM Books
WHERE price > 500
ORDER BY price DESC, title;
-- EXPECTED OUTPUT: 40 rows. Columns: book_id, title, author, category, price
--     49 | Artificial Intelligence: A Modern Approach | Stuart Russell and Peter Norvig | Technology | 1199.00
--     41 | Introduction to Algorithms | Thomas H. Cormen | Technology | 1199.00
--     42 | Database System Concepts | Abraham Silberschatz | Technology | 1099.00
--     45 | Designing Data-Intensive Applications | Martin Kleppmann | Technology | 1049.00
--     48 | Operating System Concepts | Abraham Silberschatz | Technology | 999.00
--     ... (35 more rows)

-- ---- BASIC QUERY 3 - Show all members from Hyderabad
-- The city is only stored inside the free-text address column, so LIKE is used.
-- MySQL's default collation is case-insensitive, so 'hyderabad' would match too.
SELECT member_id, name, email, phone, address
FROM Members
WHERE address LIKE '%Hyderabad%'
ORDER BY name;
-- EXPECTED OUTPUT: 16 rows. Columns: member_id, name, email, phone, address
--     15 | Aarav Rao | aarav.rao@gmail.com | 7685792740 | H.No 8-81-279, Madhapur, Hyderabad, Telangana 500081
--     82 | Aditya Agarwal | aditya.agarwal67@yahoo.in | 9686473524 | Flat 101, Miyapur, Hyderabad, Telangana 500049
--     2 | Bhavana Kumar | bhavana.kumar@yahoo.in | 9587144002 | Flat 792, Gachibowli, Hyderabad, Telangana 500032
--     51 | Charan Gupta | charan.gupta@gmail.com | 7190867751 | Flat 773, Miyapur, Hyderabad, Telangana 500049
--     3 | Ishita Shetty | ishita.shetty@gmail.com | 9519182938 | Plot 191, Miyapur, Hyderabad, Telangana 500049
--     ... (11 more rows)

-- ---- BASIC QUERY 4 - List books belonging to the Fiction category
SELECT book_id, title, author, publisher, price
FROM Books
WHERE category = 'Fiction'
ORDER BY title;
-- EXPECTED OUTPUT: 18 rows. Columns: book_id, title, author, publisher, price
--     2 | 1984 | George Orwell | Penguin Random House India | 399.00
--     15 | Animal Farm | George Orwell | Penguin Random House India | 199.00
--     17 | Beloved | Toni Morrison | Penguin Random House India | 500.00
--     14 | Brave New World | Aldous Huxley | Penguin Random House India | 299.00
--     6 | Life of Pi | Yann Martel | Penguin Random House India | 399.00
--     ... (13 more rows)

-- ---- BASIC QUERY 5 - Display books added after 2023   ** UNRESOLVED **
-- NOT IMPLEMENTED. The instructor's Books table has no date column (no added_date,
-- created_at or publication year), so "books added after 2023" cannot be answered
-- from the instructor's schema. No column was invented and no substitute query was
-- written. Ask the instructor which column or data this refers to.
SELECT 'Basic Query 5 is UNRESOLVED: Books has no date column. Clarify with the instructor.' AS unresolved_requirement;
-- EXPECTED OUTPUT: 1 row containing the message above (this is a notice, not a result)

-- ============================================================================
-- PART 6 - JOIN QUERIES
-- ============================================================================

-- ---- JOIN 1 - Show member name with their borrowed books
-- One row per borrow transaction. Members who never borrowed do not appear.
SELECT m.member_id, m.name AS member_name, b.title AS book_title,
       br.borrow_date, br.return_date, br.status
FROM Members m
INNER JOIN Borrow_Records br ON br.member_id = m.member_id
INNER JOIN Books b ON b.book_id = br.book_id
ORDER BY m.name, br.borrow_date;
-- EXPECTED OUTPUT: 200 rows. Columns: member_id, member_name, book_title, borrow_date, return_date, status
--     64 | Aarav Khan | 1984 | 2025-04-22 | 2025-04-27 | Returned
--     64 | Aarav Khan | Mindset | 2025-05-16 | 2025-05-30 | Returned
--     64 | Aarav Khan | Designing Data-Intensive Applications | 2026-01-15 | 2026-02-04 | Returned
--     62 | Aarav Menon | The Wonder That Was India | 2025-06-12 | 2025-06-24 | Returned
--     15 | Aarav Rao | Harry Potter and the Philosopher's Stone | 2025-11-22 | 2025-12-06 | Returned
--     ... (195 more rows)

-- ---- JOIN 2 - Display book title with borrow status
-- One row per borrow transaction. Books never borrowed do not appear.
SELECT b.book_id, b.title AS book_title, br.borrow_id,
       br.status AS borrow_status, b.availability_status AS current_book_status
FROM Books b
INNER JOIN Borrow_Records br ON br.book_id = b.book_id
ORDER BY b.title, br.borrow_date;
-- EXPECTED OUTPUT: 200 rows. Columns: book_id, book_title, borrow_id, borrow_status, current_book_status
--     2 | 1984 | 27 | Returned | Available
--     2 | 1984 | 32 | Returned | Available
--     2 | 1984 | 73 | Returned | Available
--     2 | 1984 | 107 | Returned | Available
--     29 | A Brief History of Time | 167 | Returned | Issued
--     ... (195 more rows)

-- ---- JOIN 3 - Show borrow details with member information
SELECT br.borrow_id, br.borrow_date, br.return_date, br.status,
       m.member_id, m.name AS member_name, m.email, m.phone
FROM Borrow_Records br
INNER JOIN Members m ON m.member_id = br.member_id
ORDER BY br.borrow_id;
-- EXPECTED OUTPUT: 200 rows. Columns: borrow_id, borrow_date, return_date, status, member_id, member_name, email, phone
--     1 | 2025-01-05 | 2025-01-20 | Returned | 42 | Manoj Das | manoj.das47@gmail.com | 6977945712
--     2 | 2025-01-08 | 2025-01-31 | Returned | 95 | Pallavi Murthy | pallavi.murthy@yahoo.in | 8960917564
--     3 | 2025-01-16 | 2025-01-22 | Returned | 47 | Varun Choudhary | varun.choudhary11@gmail.com | 7658365949
--     4 | 2025-01-23 | 2025-02-07 | Returned | 47 | Varun Choudhary | varun.choudhary11@gmail.com | 7658365949
--     5 | 2025-01-23 | 2025-02-26 | Returned | 72 | Rashmi Joshi | rashmi.joshi84@gmail.com | 9422734515
--     ... (195 more rows)

-- ---- JOIN 4 - List books with librarian name
-- Books are linked to librarians only through Borrow_Records, so a book that was
-- never borrowed (no librarian handled it) does not appear.
SELECT b.book_id, b.title AS book_title, l.librarian_id,
       l.name AS librarian_name, br.borrow_date
FROM Books b
INNER JOIN Borrow_Records br ON br.book_id = b.book_id
INNER JOIN Librarians l ON l.librarian_id = br.librarian_id
ORDER BY b.title, br.borrow_date;
-- EXPECTED OUTPUT: 200 rows. Columns: book_id, book_title, librarian_id, librarian_name, borrow_date
--     2 | 1984 | 7 | Anitha Joseph | 2025-04-22
--     2 | 1984 | 3 | Lakshmi Narayan | 2025-05-05
--     2 | 1984 | 1 | Sunitha Rao | 2025-07-26
--     2 | 1984 | 2 | Ramesh Kumar | 2025-09-30
--     29 | A Brief History of Time | 3 | Lakshmi Narayan | 2026-09-08
--     ... (195 more rows)

-- ---- JOIN 5 - Show members with the books they borrowed
-- Same relationship as JOIN 1 but one row per member (all titles in one cell).
-- Note: GROUP_CONCAT output is cut at 1024 characters by default in MySQL, so a member with many long titles may be truncated.
SELECT m.member_id, m.name AS member_name,
       COUNT(br.borrow_id) AS books_borrowed,
       GROUP_CONCAT(b.title ORDER BY b.title SEPARATOR ', ') AS books_list
FROM Members m
INNER JOIN Borrow_Records br ON br.member_id = m.member_id
INNER JOIN Books b ON b.book_id = br.book_id
GROUP BY m.member_id, m.name
ORDER BY books_borrowed DESC, m.name;
-- EXPECTED OUTPUT: 92 rows. Columns: member_id, member_name, books_borrowed, books_list
--     95 | Pallavi Murthy | 7 | A Game of Thrones, Animal Farm, Guns, Germs, and Steel, Midnight's Children, Outliers, The Lean Startup, Wuthering Heights
--     68 | Vivaan Varma | 7 | 1984, Beloved, Clean Code, Ikigai, Sapiens, SPQR, The Power of Now
--     58 | Shreya Mehta | 6 | And Then There Were None, Clean Code, Designing Data-Intensive Applications, Freedom at Midnight, Learning SQL, The Alchemist
--     ... (89 more rows)

-- ============================================================================
-- PART 7 - AGGREGATE FUNCTIONS
-- ============================================================================

-- ---- AGGREGATE 1 - Count total number of books
SELECT COUNT(*) AS total_books FROM Books;
-- EXPECTED OUTPUT: 1 row. Columns: total_books
--     100

-- ---- AGGREGATE 2 - Find average book price
SELECT ROUND(AVG(price), 2) AS average_book_price FROM Books;
-- EXPECTED OUTPUT: 1 row. Columns: average_book_price
--     520.34

-- ---- AGGREGATE 3 - Calculate total books borrowed (distinct books ever borrowed)
-- Counts each book once, no matter how many times it was borrowed.
SELECT COUNT(DISTINCT book_id) AS distinct_books_borrowed FROM Borrow_Records;
-- EXPECTED OUTPUT: 1 row. Columns: distinct_books_borrowed
--     88

-- ---- AGGREGATE 4 - Count total borrow records
-- Why 3 and 4 differ: a book borrowed 5 times is 1 in Aggregate 3 but 5 in Aggregate 4.
-- Here 88 distinct books account for 200 borrow transactions.
SELECT COUNT(*) AS total_borrow_records FROM Borrow_Records;
-- EXPECTED OUTPUT: 1 row. Columns: total_borrow_records
--     200

-- ---- AGGREGATE 5 - Find highest priced book
SELECT MAX(price) AS highest_price FROM Books;
-- EXPECTED OUTPUT: 1 row. Columns: highest_price
--     1199.00
-- The book(s) with that price (handles ties):
SELECT book_id, title, author, price
FROM Books
WHERE price = (SELECT MAX(price) FROM Books)
ORDER BY title;
-- EXPECTED OUTPUT: 2 rows. Columns: book_id, title, author, price
--     49 | Artificial Intelligence: A Modern Approach | Stuart Russell and Peter Norvig | 1199.00
--     41 | Introduction to Algorithms | Thomas H. Cormen | 1199.00

-- ============================================================================
-- PART 8 - SUBQUERIES
-- ============================================================================

-- ---- SUBQUERY 1 - Find members who never borrowed books
SELECT m.member_id, m.name, m.email, m.membership_date
FROM Members m
WHERE NOT EXISTS (SELECT 1 FROM Borrow_Records br WHERE br.member_id = m.member_id)
ORDER BY m.member_id;
-- EXPECTED OUTPUT: 8 rows. Columns: member_id, name, email, membership_date
--     11 | Ramesh Sharma | ramesh.sharma75@gmail.com | 2022-06-20
--     24 | Vamsi Gupta | vamsi.gupta13@gmail.com | 2025-06-19
--     25 | Madhavi Banerjee | madhavi.banerjee@outlook.com | 2022-12-10
--     37 | Rahul Banerjee | rahul.banerjee@gmail.com | 2022-11-04
--     55 | Arjun Yadav | arjun.yadav29@gmail.com | 2022-06-08
--     56 | Nikhil Kumar | nikhil.kumar@rediffmail.com | 2025-05-26
--     70 | Krishna Rao | krishna.rao@yahoo.in | 2022-11-03
--     78 | Ravi Banerjee | ravi.banerjee@outlook.com | 2025-05-13

-- ---- SUBQUERY 2 - Find books never borrowed
SELECT b.book_id, b.title, b.author, b.category, b.availability_status
FROM Books b
WHERE NOT EXISTS (SELECT 1 FROM Borrow_Records br WHERE br.book_id = b.book_id)
ORDER BY b.book_id;
-- EXPECTED OUTPUT: 12 rows. Columns: book_id, title, author, category, availability_status
--     8 | One Hundred Years of Solitude | Gabriel Garcia Marquez | Fiction | Available
--     20 | Educated | Tara Westover | Non-Fiction | Available
--     31 | The Selfish Gene | Richard Dawkins | Science | Available
--     34 | The Elegant Universe | Brian Greene | Science | Available
--     41 | Introduction to Algorithms | Thomas H. Cormen | Technology | Available
--     55 | The Diary of a Young Girl | Anne Frank | History | Available
--     68 | I Am Malala | Malala Yousafzai | Biography | Available
--     71 | The Fellowship of the Ring | J. R. R. Tolkien | Fantasy | Available
--     73 | The Lion, the Witch and the Wardrobe | C. S. Lewis | Fantasy | Available
--     77 | The Girl with the Dragon Tattoo | Stieg Larsson | Mystery | Available
--     86 | The 7 Habits of Highly Effective People | Stephen R. Covey | Self-Help | Available
--     98 | Shoe Dog | Phil Knight | Business | Available

-- ---- SUBQUERY 3 - Show books with price greater than the average price
SELECT book_id, title, category, price
FROM Books
WHERE price > (SELECT AVG(price) FROM Books)
ORDER BY price DESC, title;
-- EXPECTED OUTPUT: 40 rows. Columns: book_id, title, category, price
--     49 | Artificial Intelligence: A Modern Approach | Technology | 1199.00
--     41 | Introduction to Algorithms | Technology | 1199.00
--     42 | Database System Concepts | Technology | 1099.00
--     45 | Designing Data-Intensive Applications | Technology | 1049.00
--     48 | Operating System Concepts | Technology | 999.00
--     ... (35 more rows)

-- ---- SUBQUERY 4 - Find members who borrowed more than the average number of books
-- Average = borrow records per member, over members who borrowed at least once
-- (200 records / 92 borrowing members = about 2.17), so members with 3 or more qualify.
SELECT m.member_id, m.name, COUNT(*) AS books_borrowed
FROM Members m
INNER JOIN Borrow_Records br ON br.member_id = m.member_id
GROUP BY m.member_id, m.name
HAVING COUNT(*) > (
    SELECT AVG(t.books_per_member)
    FROM (SELECT COUNT(*) AS books_per_member
          FROM Borrow_Records
          GROUP BY member_id) t
)
ORDER BY books_borrowed DESC, m.name;
-- EXPECTED OUTPUT: 24 rows. Columns: member_id, name, books_borrowed
--     95 | Pallavi Murthy | 7
--     68 | Vivaan Varma | 7
--     58 | Shreya Mehta | 6
--     4 | Shreya Reddy | 6
--     9 | Kiran Ahmed | 5
--     ... (19 more rows)

-- ---- SUBQUERY 5 - Show borrow records above the average duration
-- Duration = return_date - borrow_date, using Returned records only (Borrowed rows have no return_date).
-- Average duration of returned loans: 21.76 days.
SELECT borrow_id, member_id, book_id, borrow_date, return_date,
       DATEDIFF(return_date, borrow_date) AS duration_days
FROM Borrow_Records
WHERE status = 'Returned'
  AND DATEDIFF(return_date, borrow_date) > (
      SELECT AVG(DATEDIFF(return_date, borrow_date))
      FROM Borrow_Records
      WHERE status = 'Returned')
ORDER BY duration_days DESC, borrow_id;
-- EXPECTED OUTPUT: 87 rows. Columns: borrow_id, member_id, book_id, borrow_date, return_date, duration_days
--     55 | 71 | 1 | 2025-06-19 | 2025-07-27 | 38
--     70 | 53 | 10 | 2025-07-20 | 2025-08-27 | 38
--     78 | 68 | 88 | 2025-08-02 | 2025-09-09 | 38
--     82 | 88 | 4 | 2025-08-06 | 2025-09-13 | 38
--     125 | 31 | 85 | 2025-12-24 | 2026-01-31 | 38
--     ... (82 more rows)

-- ============================================================================
-- PART 9 - STORED PROCEDURES
-- ============================================================================
-- Each procedure is created, then called, then verified.
-- Calls that change data run inside START TRANSACTION ... ROLLBACK so the data
-- (and every expected output in this script) stays exactly as loaded in PART 3.
-- Workbench handles the DELIMITER lines; if you run this in another client, make sure it supports DELIMITER.

-- ---- PROCEDURE 1 - Insert a new member (name, email, phone, address, membership_date)
-- CONCURRENCY LIMITATION (by design, to keep the instructor's DDL without AUTO_INCREMENT):
-- the new member_id is MAX(member_id) + 1. If two sessions call this procedure at
-- the same moment they can read the same MAX; the second INSERT then fails with a
-- duplicate-key error (1062) on the primary key. No duplicate ids are ever stored,
-- but the failed call has to be repeated. AUTO_INCREMENT (recommendation 2) would
-- remove this limitation.
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_insert_member$$
CREATE PROCEDURE sp_insert_member(
    IN p_name            VARCHAR(100),
    IN p_email           VARCHAR(100),
    IN p_phone           VARCHAR(15),
    IN p_address         VARCHAR(255),
    IN p_membership_date DATE
)
BEGIN
    DECLARE v_new_member_id INT;

    -- next id = highest existing id + 1 (1 if the table is empty)
    SELECT COALESCE(MAX(member_id), 0) + 1 INTO v_new_member_id FROM Members;

    INSERT INTO Members (member_id, name, email, phone, address, membership_date)
    VALUES (v_new_member_id, p_name, p_email, p_phone, p_address, p_membership_date);

    -- show the id that was assigned
    SELECT v_new_member_id AS new_member_id;
END$$
DELIMITER ;

-- Test inside a transaction so the data is restored afterwards.
START TRANSACTION;
CALL sp_insert_member('Test Member', 'test.member@example.com', '9876500000', '12 Test Street, Hyderabad, Telangana 500001', '2026-11-13');
-- EXPECTED OUTPUT: 1 row. new_member_id = 101
SELECT member_id, name, email, address, membership_date FROM Members WHERE member_id = 101;
-- EXPECTED OUTPUT: 1 row. 101 | Test Member | test.member@example.com | 12 Test Street, Hyderabad, Telangana 500001 | 2026-11-13
SELECT COUNT(*) AS members_during_test FROM Members;
-- EXPECTED OUTPUT: members_during_test = 101
ROLLBACK;
SELECT COUNT(*) AS members_after_rollback FROM Members;
-- EXPECTED OUTPUT: members_after_rollback = 100

-- ---- PROCEDURE 2 - Update book price (book_id, new_price)
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_book_price$$
CREATE PROCEDURE sp_update_book_price(
    IN p_book_id   INT,
    IN p_new_price DECIMAL(10,2)
)
BEGIN
    UPDATE Books
    SET price = p_new_price
    WHERE book_id = p_book_id;

    -- show the book after the update (empty result if the book_id does not exist)
    SELECT book_id, title, price FROM Books WHERE book_id = p_book_id;
END$$
DELIMITER ;

START TRANSACTION;
CALL sp_update_book_price(1, 349.00);
-- EXPECTED OUTPUT: 1 row. 1 | To Kill a Mockingbird | 349.00   (was 299.00)
ROLLBACK;
SELECT book_id, title, price FROM Books WHERE book_id = 1;
-- EXPECTED OUTPUT: 1 row. 1 | To Kill a Mockingbird | 299.00   (original price restored)

-- ---- PROCEDURE 3 - Display borrow records of a member (member_id)
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_member_borrow_records$$
CREATE PROCEDURE sp_member_borrow_records(
    IN p_member_id INT
)
BEGIN
    SELECT br.borrow_id, br.member_id, br.book_id, b.title AS book_title,
           br.librarian_id, br.borrow_date, br.return_date, br.status
    FROM Borrow_Records br
    INNER JOIN Books b ON b.book_id = br.book_id
    WHERE br.member_id = p_member_id
    ORDER BY br.borrow_date;
END$$
DELIMITER ;

CALL sp_member_borrow_records(68);
-- (member 68, Vivaan Varma, is the most active member)
-- EXPECTED OUTPUT: 7 rows. Columns: borrow_id, member_id, book_id, book_title, librarian_id, borrow_date, return_date, status
--     19 | 68 | 19 | Sapiens | 3 | 2025-03-22 | 2025-03-28 | Returned
--     39 | 68 | 89 | The Power of Now | 3 | 2025-05-18 | 2025-05-30 | Returned
--     73 | 68 | 2 | 1984 | 1 | 2025-07-26 | 2025-08-16 | Returned
--     78 | 68 | 88 | Ikigai | 10 | 2025-08-02 | 2025-09-09 | Returned
--     130 | 68 | 39 | Clean Code | 10 | 2026-01-23 | 2026-03-02 | Returned
--     161 | 68 | 17 | Beloved | 7 | 2026-08-12 | NULL | Borrowed
--     198 | 68 | 56 | SPQR | 9 | 2026-11-04 | NULL | Borrowed
-- A member who never borrowed returns an empty result, e.g. CALL sp_member_borrow_records(11);  -- EXPECTED: 0 rows

-- ---- PROCEDURE 4 - Calculate total borrowed books
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_total_borrowed_books$$
CREATE PROCEDURE sp_total_borrowed_books(
    OUT p_total_borrow_records INT
)
BEGIN
    -- OUT parameter: total number of borrow transactions
    SELECT COUNT(*) INTO p_total_borrow_records FROM Borrow_Records;

    -- result set: both counts side by side (see PART 7, Aggregates 3 and 4)
    SELECT p_total_borrow_records AS total_borrow_records,
           (SELECT COUNT(DISTINCT book_id) FROM Borrow_Records) AS distinct_books_borrowed;
END$$
DELIMITER ;

CALL sp_total_borrowed_books(@total_borrowed);
-- EXPECTED OUTPUT: 1 row. total_borrow_records = 200 | distinct_books_borrowed = 88
SELECT @total_borrowed AS total_borrowed_out_parameter;
-- EXPECTED OUTPUT: 1 row. total_borrowed_out_parameter = 200

-- ---- PROCEDURE 5 - List books of a category (category)
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_books_by_category$$
CREATE PROCEDURE sp_books_by_category(
    IN p_category VARCHAR(50)
)
BEGIN
    SELECT book_id, title, author, publisher, price, availability_status
    FROM Books
    WHERE category = p_category
    ORDER BY title;
END$$
DELIMITER ;

CALL sp_books_by_category('Fiction');
-- EXPECTED OUTPUT: 18 rows. Columns: book_id, title, author, publisher, price, availability_status
--     2 | 1984 | George Orwell | Penguin Random House India | 399.00 | Available
--     15 | Animal Farm | George Orwell | Penguin Random House India | 199.00 | Available
--     17 | Beloved | Toni Morrison | Penguin Random House India | 500.00 | Issued
--     14 | Brave New World | Aldous Huxley | Penguin Random House India | 299.00 | Available
--     ... (14 more rows)

-- ============================================================================
-- PART 10 - UPDATE OPERATIONS (each one inside a transaction and rolled back)
-- ============================================================================
-- Each update shows the row before, applies the change, shows the row after,
-- then ROLLBACK restores the original data, which the last SELECT proves.

-- ---- UPDATE 1 - Update book price
START TRANSACTION;
SELECT book_id, title, price FROM Books WHERE book_id = 5;
-- EXPECTED (before): 5 | The Kite Runner | 449.00
UPDATE Books SET price = 549.00 WHERE book_id = 5;
SELECT book_id, title, price FROM Books WHERE book_id = 5;
-- EXPECTED (after): 5 | The Kite Runner | 549.00
ROLLBACK;
SELECT book_id, title, price FROM Books WHERE book_id = 5;
-- EXPECTED (restored): 5 | The Kite Runner | 449.00

-- ---- UPDATE 2 - Change member email
START TRANSACTION;
SELECT member_id, name, email FROM Members WHERE member_id = 10;
-- EXPECTED (before): 10 | Rohan Singh | rohan.singh@gmail.com
UPDATE Members SET email = 'updated.email@example.com' WHERE member_id = 10;
SELECT member_id, name, email FROM Members WHERE member_id = 10;
-- EXPECTED (after): 10 | Rohan Singh | updated.email@example.com
ROLLBACK;
SELECT member_id, name, email FROM Members WHERE member_id = 10;
-- EXPECTED (restored): 10 | Rohan Singh | rohan.singh@gmail.com

-- ---- UPDATE 3 - Update book category
START TRANSACTION;
SELECT book_id, title, category FROM Books WHERE book_id = 12;
-- EXPECTED (before): 12 | Train to Pakistan | Fiction
UPDATE Books SET category = 'Historical Fiction' WHERE book_id = 12;
SELECT book_id, title, category FROM Books WHERE book_id = 12;
-- EXPECTED (after): 12 | Train to Pakistan | Historical Fiction
ROLLBACK;
SELECT book_id, title, category FROM Books WHERE book_id = 12;
-- EXPECTED (restored): 12 | Train to Pakistan | Fiction

-- ============================================================================
-- PART 11 - DELETE OPERATIONS (destructive, so each one is rolled back)
-- ============================================================================
-- MySQL Workbench 'Safe Updates' mode blocks DELETE statements that do not filter on a
-- key column (error 1175). Safe updates are switched off for this part and restored at the end.
SET @previous_safe_updates = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

-- ---- DELETE 4 - Delete returned records
START TRANSACTION;
SELECT COUNT(*) AS total_before, SUM(status = 'Returned') AS returned_before FROM Borrow_Records;
-- EXPECTED: total_before = 200 | returned_before = 170
DELETE FROM Borrow_Records WHERE status = 'Returned';
-- EXPECTED: 170 rows affected
SELECT COUNT(*) AS total_after_delete, SUM(status = 'Borrowed') AS borrowed_after_delete FROM Borrow_Records;
-- EXPECTED: total_after_delete = 30 | borrowed_after_delete = 30  (only open loans remain)
ROLLBACK;
SELECT COUNT(*) AS total_after_rollback FROM Borrow_Records;
-- EXPECTED: total_after_rollback = 200  (all records restored)

-- ---- DELETE 5 - Delete members with no borrow history (skipping members who have reservations)
-- A member who has a reservation cannot be deleted while the reservation exists: the
-- foreign key on Reservations.member_id would raise error 1451. Those members are skipped.
-- Preview 1: members with no borrow history AND no reservations (these will be deleted).
SELECT m.member_id, m.name
FROM Members m
WHERE NOT EXISTS (SELECT 1 FROM Borrow_Records br WHERE br.member_id = m.member_id)
  AND NOT EXISTS (SELECT 1 FROM Reservations r WHERE r.member_id = m.member_id)
ORDER BY m.member_id;
-- EXPECTED: 3 rows: member_id 56, 70, 78

-- Preview 2: members with no borrow history but WITH reservations (these are skipped).
SELECT m.member_id, m.name
FROM Members m
WHERE NOT EXISTS (SELECT 1 FROM Borrow_Records br WHERE br.member_id = m.member_id)
  AND EXISTS (SELECT 1 FROM Reservations r WHERE r.member_id = m.member_id)
ORDER BY m.member_id;
-- EXPECTED: 5 rows: member_id 11, 24, 25, 37, 55

START TRANSACTION;
DELETE FROM Members
WHERE NOT EXISTS (SELECT 1 FROM Borrow_Records br WHERE br.member_id = Members.member_id)
  AND NOT EXISTS (SELECT 1 FROM Reservations r WHERE r.member_id = Members.member_id);
-- EXPECTED: 3 rows affected
SELECT COUNT(*) AS members_after_delete FROM Members;
-- EXPECTED: members_after_delete = 97
ROLLBACK;
SELECT COUNT(*) AS members_after_rollback FROM Members;
-- EXPECTED: members_after_rollback = 100  (all members restored)

-- Not run on purpose: deleting a member that has reservations would fail with error 1451.
-- DELETE FROM Members WHERE member_id = 11;

SET SQL_SAFE_UPDATES = @previous_safe_updates;

-- ============================================================================
-- PART 12 - VIEWS, TRIGGERS (none required) AND REPORTS / ANALYSIS
-- ============================================================================
-- The instructor's document lists five views and no triggers, so no triggers are created.

-- ---- VIEW 1 - Member borrow records
CREATE OR REPLACE VIEW vw_member_borrow_records AS
SELECT m.member_id, m.name AS member_name, br.borrow_id, b.book_id,
       b.title AS book_title, br.borrow_date, br.return_date, br.status
FROM Members m
INNER JOIN Borrow_Records br ON br.member_id = m.member_id
INNER JOIN Books b ON b.book_id = br.book_id;
SELECT COUNT(*) AS rows_in_vw_member_borrow_records FROM vw_member_borrow_records;
-- EXPECTED OUTPUT: rows_in_vw_member_borrow_records = 200
SELECT * FROM vw_member_borrow_records ORDER BY borrow_id LIMIT 5;
-- EXPECTED OUTPUT: 5 rows. Columns: member_id, member_name, borrow_id, book_id, book_title, borrow_date, return_date, status
--     42 | Manoj Das | 1 | 49 | Artificial Intelligence: A Modern Approach | 2025-01-05 | 2025-01-20 | Returned
--     95 | Pallavi Murthy | 2 | 18 | Wuthering Heights | 2025-01-08 | 2025-01-31 | Returned
--     47 | Varun Choudhary | 3 | 12 | Train to Pakistan | 2025-01-16 | 2025-01-22 | Returned
--     47 | Varun Choudhary | 4 | 64 | Long Walk to Freedom | 2025-01-23 | 2025-02-07 | Returned
--     72 | Rashmi Joshi | 5 | 65 | Becoming | 2025-01-23 | 2025-02-26 | Returned

-- ---- VIEW 2 - Book details
-- Borrow and reservation counts are pre-aggregated in separate subqueries, so joining
-- both tables cannot multiply the rows (no double counting).
CREATE OR REPLACE VIEW vw_book_details AS
SELECT b.book_id, b.title, b.author, b.publisher, b.category, b.price,
       b.availability_status,
       COALESCE(bc.times_borrowed, 0) AS times_borrowed,
       COALESCE(rc.times_reserved, 0) AS times_reserved
FROM Books b
LEFT JOIN (SELECT book_id, COUNT(*) AS times_borrowed FROM Borrow_Records GROUP BY book_id) bc
       ON bc.book_id = b.book_id
LEFT JOIN (SELECT book_id, COUNT(*) AS times_reserved FROM Reservations GROUP BY book_id) rc
       ON rc.book_id = b.book_id;
SELECT COUNT(*) AS rows_in_vw_book_details FROM vw_book_details;
-- EXPECTED OUTPUT: rows_in_vw_book_details = 100
SELECT * FROM vw_book_details ORDER BY book_id LIMIT 5;
-- EXPECTED OUTPUT: 5 rows. Columns: book_id, title, author, publisher, category, price, availability_status, times_borrowed, times_reserved
--     1 | To Kill a Mockingbird | Harper Lee | HarperCollins | Fiction | 299.00 | Available | 2 | 2
--     2 | 1984 | George Orwell | Penguin Random House India | Fiction | 399.00 | Available | 4 | 0
--     3 | The Great Gatsby | F. Scott Fitzgerald | Penguin Random House India | Fiction | 249.00 | Issued | 1 | 1
--     4 | Pride and Prejudice | Jane Austen | Penguin Random House India | Fiction | 199.00 | Available | 1 | 1
--     5 | The Kite Runner | Khaled Hosseini | Bloomsbury | Fiction | 449.00 | Available | 1 | 0

-- ---- VIEW 3 - Borrow details with member and book
CREATE OR REPLACE VIEW vw_borrow_details AS
SELECT br.borrow_id, br.borrow_date, br.return_date, br.status,
       m.member_id, m.name AS member_name, m.email AS member_email,
       b.book_id, b.title AS book_title, b.category,
       l.librarian_id, l.name AS librarian_name
FROM Borrow_Records br
INNER JOIN Members m ON m.member_id = br.member_id
INNER JOIN Books b ON b.book_id = br.book_id
INNER JOIN Librarians l ON l.librarian_id = br.librarian_id;
SELECT COUNT(*) AS rows_in_vw_borrow_details FROM vw_borrow_details;
-- EXPECTED OUTPUT: rows_in_vw_borrow_details = 200
SELECT * FROM vw_borrow_details ORDER BY borrow_id LIMIT 3;
-- EXPECTED OUTPUT: 3 rows. Columns: borrow_id, borrow_date, return_date, status, member_id, member_name, member_email, book_id, book_title, category, librarian_id, librarian_name
--     1 | 2025-01-05 | 2025-01-20 | Returned | 42 | Manoj Das | manoj.das47@gmail.com | 49 | Artificial Intelligence: A Modern Approach | Technology | 9 | Farah Khan
--     2 | 2025-01-08 | 2025-01-31 | Returned | 95 | Pallavi Murthy | pallavi.murthy@yahoo.in | 18 | Wuthering Heights | Fiction | 2 | Ramesh Kumar
--     3 | 2025-01-16 | 2025-01-22 | Returned | 47 | Varun Choudhary | varun.choudhary11@gmail.com | 12 | Train to Pakistan | Fiction | 10 | Deepa Nair

-- ---- VIEW 4 - Total books borrowed by each member
-- LEFT JOIN keeps members who never borrowed (total_books_borrowed = 0).
CREATE OR REPLACE VIEW vw_member_total_borrowed AS
SELECT m.member_id, m.name AS member_name,
       COUNT(br.borrow_id) AS total_books_borrowed
FROM Members m
LEFT JOIN Borrow_Records br ON br.member_id = m.member_id
GROUP BY m.member_id, m.name;
SELECT COUNT(*) AS rows_in_vw_member_total_borrowed FROM vw_member_total_borrowed;
-- EXPECTED OUTPUT: rows_in_vw_member_total_borrowed = 100
SELECT * FROM vw_member_total_borrowed ORDER BY total_books_borrowed DESC, member_id LIMIT 5;
-- EXPECTED OUTPUT: 5 rows. Columns: member_id, member_name, total_books_borrowed
--     68 | Vivaan Varma | 7
--     95 | Pallavi Murthy | 7
--     4 | Shreya Reddy | 6
--     58 | Shreya Mehta | 6
--     9 | Kiran Ahmed | 5

-- ---- VIEW 5 - Most borrowed books
-- Only books that were borrowed at least once appear. Sort when you query the view.
CREATE OR REPLACE VIEW vw_most_borrowed_books AS
SELECT b.book_id, b.title, b.author, b.category,
       COUNT(br.borrow_id) AS times_borrowed
FROM Books b
INNER JOIN Borrow_Records br ON br.book_id = b.book_id
GROUP BY b.book_id, b.title, b.author, b.category;
SELECT COUNT(*) AS rows_in_vw_most_borrowed_books FROM vw_most_borrowed_books;
-- EXPECTED OUTPUT: rows_in_vw_most_borrowed_books = 88
SELECT * FROM vw_most_borrowed_books ORDER BY times_borrowed DESC, title LIMIT 5;
-- EXPECTED OUTPUT: 5 rows. Columns: book_id, title, author, category, times_borrowed
--     85 | Atomic Habits | James Clear | Self-Help | 7
--     45 | Designing Data-Intensive Applications | Martin Kleppmann | Technology | 7
--     40 | The Pragmatic Programmer | Andrew Hunt and David Thomas | Technology | 7
--     7 | The Alchemist | Paulo Coelho | Fiction | 6
--     95 | The Lean Startup | Eric Ries | Business | 6

-- ============================================================================
-- REPORTS / ANALYSIS (instructor's six reports)
-- ============================================================================

-- ---- REPORT 1 - Top 5 most borrowed books
-- Ties are broken alphabetically by title.
SELECT b.book_id, b.title, b.author, COUNT(*) AS times_borrowed
FROM Borrow_Records br
INNER JOIN Books b ON b.book_id = br.book_id
GROUP BY b.book_id, b.title, b.author
ORDER BY times_borrowed DESC, b.title
LIMIT 5;
-- EXPECTED OUTPUT: 5 rows. Columns: book_id, title, author, times_borrowed
--     85 | Atomic Habits | James Clear | 7
--     45 | Designing Data-Intensive Applications | Martin Kleppmann | 7
--     40 | The Pragmatic Programmer | Andrew Hunt and David Thomas | 7
--     7 | The Alchemist | Paulo Coelho | 6
--     95 | The Lean Startup | Eric Ries | 6

-- ---- REPORT 2 - Most active members (top 5 by number of borrow records)
-- Ties are broken alphabetically by member name.
SELECT m.member_id, m.name, COUNT(*) AS books_borrowed
FROM Borrow_Records br
INNER JOIN Members m ON m.member_id = br.member_id
GROUP BY m.member_id, m.name
ORDER BY books_borrowed DESC, m.name
LIMIT 5;
-- EXPECTED OUTPUT: 5 rows. Columns: member_id, name, books_borrowed
--     95 | Pallavi Murthy | 7
--     68 | Vivaan Varma | 7
--     58 | Shreya Mehta | 6
--     4 | Shreya Reddy | 6
--     9 | Kiran Ahmed | 5

-- ---- REPORT 3 - Monthly borrow report
SELECT DATE_FORMAT(borrow_date, '%Y-%m') AS borrow_month,
       COUNT(*) AS books_borrowed
FROM Borrow_Records
GROUP BY DATE_FORMAT(borrow_date, '%Y-%m')
ORDER BY borrow_month;
-- EXPECTED OUTPUT: 23 rows. Columns: borrow_month, books_borrowed
--     2025-01 | 6
--     2025-02 | 8
--     2025-03 | 7
--     2025-04 | 10
--     2025-05 | 13
--     2025-06 | 14
--     ... (17 more rows)

-- ---- REPORT 4 - Most popular category (ranking, then the top category)
SELECT b.category, COUNT(*) AS times_borrowed
FROM Borrow_Records br
INNER JOIN Books b ON b.book_id = br.book_id
GROUP BY b.category
ORDER BY times_borrowed DESC, b.category;
-- EXPECTED OUTPUT: 10 rows. Columns: category, times_borrowed
--     Fiction | 38
--     Technology | 35
--     Self-Help | 23
--     Business | 20
--     Non-Fiction | 18
--     Mystery | 16
--     Science | 15
--     Fantasy | 14
--     History | 11
--     Biography | 10

-- ---- REPORT 4b - Most popular category (top only, ties included)
SELECT b.category, COUNT(*) AS times_borrowed
FROM Borrow_Records br
INNER JOIN Books b ON b.book_id = br.book_id
GROUP BY b.category
HAVING COUNT(*) = (
    SELECT MAX(t.cnt)
    FROM (SELECT COUNT(*) AS cnt
          FROM Borrow_Records br2
          INNER JOIN Books b2 ON b2.book_id = br2.book_id
          GROUP BY b2.category) t
);
-- EXPECTED OUTPUT: 1 row. Columns: category, times_borrowed
--     Fiction | 38

-- ---- REPORT 5 - Member borrowing analysis
-- One row per member (100 rows). Members who never borrowed show 0 and NULL dates.
SELECT m.member_id, m.name,
       COUNT(br.borrow_id) AS total_borrowed,
       SUM(CASE WHEN br.status = 'Returned' THEN 1 ELSE 0 END) AS returned_count,
       SUM(CASE WHEN br.status = 'Borrowed' THEN 1 ELSE 0 END) AS currently_borrowed,
       ROUND(AVG(CASE WHEN br.status = 'Returned'
                      THEN DATEDIFF(br.return_date, br.borrow_date) END), 1) AS avg_days_kept,
       MIN(br.borrow_date) AS first_borrow_date,
       MAX(br.borrow_date) AS last_borrow_date
FROM Members m
LEFT JOIN Borrow_Records br ON br.member_id = m.member_id
GROUP BY m.member_id, m.name
ORDER BY total_borrowed DESC, m.name;
-- EXPECTED OUTPUT: 100 rows. Columns: member_id, name, total_borrowed, returned_count, currently_borrowed, avg_days_kept, first_borrow_date, last_borrow_date
--     95 | Pallavi Murthy | 7 | 6 | 1 | 18 | 2025-01-08 | 2026-10-17
--     68 | Vivaan Varma | 7 | 5 | 2 | 23 | 2025-03-22 | 2026-11-04
--     58 | Shreya Mehta | 6 | 5 | 1 | 24.6 | 2025-02-17 | 2026-10-26
--     4 | Shreya Reddy | 6 | 4 | 2 | 15 | 2025-07-13 | 2026-10-28
--     ... (96 more rows)

-- ---- REPORT 6 - Highest demanded books (demand = borrow count + reservation count, top 10)
-- Borrows and reservations are counted in separate subqueries and then added, so the
-- joins cannot multiply rows (no double counting).
SELECT b.book_id, b.title,
       COALESCE(bc.borrow_count, 0) AS borrow_count,
       COALESCE(rc.reservation_count, 0) AS reservation_count,
       COALESCE(bc.borrow_count, 0) + COALESCE(rc.reservation_count, 0) AS demand
FROM Books b
LEFT JOIN (SELECT book_id, COUNT(*) AS borrow_count
           FROM Borrow_Records GROUP BY book_id) bc ON bc.book_id = b.book_id
LEFT JOIN (SELECT book_id, COUNT(*) AS reservation_count
           FROM Reservations GROUP BY book_id) rc ON rc.book_id = b.book_id
ORDER BY demand DESC, b.title
LIMIT 10;
-- EXPECTED OUTPUT: 10 rows. Columns: book_id, title, borrow_count, reservation_count, demand
--     85 | Atomic Habits | 7 | 1 | 8
--     45 | Designing Data-Intensive Applications | 7 | 1 | 8
--     40 | The Pragmatic Programmer | 7 | 1 | 8
--     94 | Zero to One | 6 | 1 | 7
--     78 | Gone Girl | 5 | 1 | 6
--     87 | How to Win Friends and Influence People | 5 | 1 | 6
--     7 | The Alchemist | 6 | 0 | 6
--     95 | The Lean Startup | 6 | 0 | 6
--     39 | Clean Code | 5 | 0 | 5
--     23 | Freakonomics | 2 | 3 | 5

-- ============================================================================
-- PART 13 - FINAL VERIFICATION
-- ============================================================================

-- ---- 13A Row counts after all the rolled-back tests (must equal PART 3)
SELECT 'Books' AS table_name, 100 AS expected_rows, COUNT(*) AS actual_rows,
       CASE WHEN COUNT(*) = 100 THEN 'PASS' ELSE 'FAIL' END AS result FROM Books
UNION ALL SELECT 'Members', 100, COUNT(*), CASE WHEN COUNT(*) = 100 THEN 'PASS' ELSE 'FAIL' END FROM Members
UNION ALL SELECT 'Librarians', 10, COUNT(*), CASE WHEN COUNT(*) = 10 THEN 'PASS' ELSE 'FAIL' END FROM Librarians
UNION ALL SELECT 'Borrow_Records', 200, COUNT(*), CASE WHEN COUNT(*) = 200 THEN 'PASS' ELSE 'FAIL' END FROM Borrow_Records
UNION ALL SELECT 'Reservations', 60, COUNT(*), CASE WHEN COUNT(*) = 60 THEN 'PASS' ELSE 'FAIL' END FROM Reservations;
-- EXPECTED OUTPUT: 5 rows, result = PASS in every row

-- ---- 13B Inventory and status consistency after all tests
SELECT 'Issued books equal books with an open loan' AS check_name,
       CASE WHEN (SELECT COUNT(*) FROM Books WHERE availability_status = 'Issued')
               = (SELECT COUNT(DISTINCT book_id) FROM Borrow_Records WHERE status = 'Borrowed')
            THEN 'PASS' ELSE 'FAIL' END AS result
UNION ALL SELECT 'No orphan rows in Borrow_Records or Reservations',
       CASE WHEN (SELECT COUNT(*) FROM Borrow_Records br LEFT JOIN Members m ON m.member_id = br.member_id WHERE m.member_id IS NULL)
              + (SELECT COUNT(*) FROM Borrow_Records br LEFT JOIN Books b ON b.book_id = br.book_id WHERE b.book_id IS NULL)
              + (SELECT COUNT(*) FROM Borrow_Records br LEFT JOIN Librarians l ON l.librarian_id = br.librarian_id WHERE l.librarian_id IS NULL)
              + (SELECT COUNT(*) FROM Reservations r LEFT JOIN Members m ON m.member_id = r.member_id WHERE m.member_id IS NULL)
              + (SELECT COUNT(*) FROM Reservations r LEFT JOIN Books b ON b.book_id = r.book_id WHERE b.book_id IS NULL) = 0
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL SELECT 'Returned rows have a return_date, Borrowed rows do not',
       CASE WHEN (SELECT COUNT(*) FROM Borrow_Records WHERE (status = 'Returned' AND return_date IS NULL) OR (status = 'Borrowed' AND return_date IS NOT NULL)) = 0
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL SELECT 'Distinct books borrowed = 88 and borrow records = 200',
       CASE WHEN (SELECT COUNT(DISTINCT book_id) FROM Borrow_Records) = 88
             AND (SELECT COUNT(*) FROM Borrow_Records) = 200
            THEN 'PASS' ELSE 'FAIL' END;
-- EXPECTED OUTPUT: 4 rows, result = PASS in every row

-- ---- 13C Stored procedures and views that exist
SELECT ROUTINE_NAME, ROUTINE_TYPE
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'library_management'
ORDER BY ROUTINE_NAME;
-- EXPECTED OUTPUT: 5 rows (all PROCEDURE): sp_books_by_category, sp_insert_member,
--   sp_member_borrow_records, sp_total_borrowed_books, sp_update_book_price

SELECT TABLE_NAME AS view_name
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'library_management'
ORDER BY TABLE_NAME;
-- EXPECTED OUTPUT: 5 rows: vw_book_details, vw_borrow_details, vw_member_borrow_records,
--   vw_member_total_borrowed, vw_most_borrowed_books

-- ---- 13D View row counts versus their base tables
SELECT 'vw_member_borrow_records' AS view_name, COUNT(*) AS row_count FROM vw_member_borrow_records
UNION ALL SELECT 'vw_book_details', COUNT(*) FROM vw_book_details
UNION ALL SELECT 'vw_borrow_details', COUNT(*) FROM vw_borrow_details
UNION ALL SELECT 'vw_member_total_borrowed', COUNT(*) FROM vw_member_total_borrowed
UNION ALL SELECT 'vw_most_borrowed_books', COUNT(*) FROM vw_most_borrowed_books;
-- EXPECTED OUTPUT: 5 rows
--     vw_member_borrow_records | 200   (= Borrow_Records rows)
--     vw_book_details | 100   (= Books rows)
--     vw_borrow_details | 200   (= Borrow_Records rows)
--     vw_member_total_borrowed | 100   (= Members rows)
--     vw_most_borrowed_books | 88   (= distinct books borrowed)

-- Reconciliation: the totals in the views must add up to the base tables.
SELECT
  (SELECT SUM(total_books_borrowed) FROM vw_member_total_borrowed) AS borrows_per_member_total,
  (SELECT SUM(times_borrowed) FROM vw_most_borrowed_books)         AS borrows_per_book_total,
  (SELECT SUM(times_borrowed) FROM vw_book_details)                AS borrows_in_book_details,
  (SELECT SUM(times_reserved) FROM vw_book_details)                AS reservations_in_book_details;
-- EXPECTED OUTPUT: 1 row. 200 | 200 | 200 | 60

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
