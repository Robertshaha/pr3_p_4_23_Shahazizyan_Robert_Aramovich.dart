import 'dart:io';

abstract class Person {
  final String fullName;
  final String email;
  final String phoneNumber;

  Person(this.fullName, this.email, this.phoneNumber);

  void displayInfo();
}

class Book {
  final String title;
  final String author;
  final String isbn;
  bool _isAvailable;

  Book(this.title, this.author, this.isbn) : _isAvailable = true;

  bool get isAvailable => _isAvailable;

  void markAsBorrowed() => _isAvailable = false;
  void markAsReturned() => _isAvailable = true;

  @override
  String toString() => "'$title' автор $author (ISBN: $isbn)";
}

class Member extends Person {
  final DateTime registrationDate;
  List<Book> borrowedBooks = [];

  Member(String fullName, String email, String phoneNumber, this.registrationDate)
      : super(fullName, email, phoneNumber);

  void borrowBook(Book book) {
    borrowedBooks.add(book);
    book.markAsBorrowed();
  }

  void returnBook(Book book) {
    borrowedBooks.remove(book);
    book.markAsReturned();
  }

  @override
  void displayInfo() {
    print('''
Информация о члене библиотеки:
  Имя: $fullName
  Email: $email
  Телефон: $phoneNumber
  Дата регистрации: ${registrationDate.toLocal()}
  Книг на руках: ${borrowedBooks.length}''');
  }
}

class Author extends Person {
  final String biography;
  final List<Book> publishedBooks = [];

  Author(String fullName, String email, String phoneNumber, this.biography)
      : super(fullName, email, phoneNumber);

  void addPublishedBook(Book book) {
    publishedBooks.add(book);
  }

  @override
  void displayInfo() {
    print('''
Информация об авторе:
  Имя: $fullName
  Email: $email
  Телефон: $phoneNumber
  Биография: $biography
  Опубликованных книг: ${publishedBooks.length}''');
  }
}

class Loan {
  final Member member;
  final Book book;
  final DateTime loanDate;
  DateTime? _returnDate;

  Loan(this.member, this.book, this.loanDate) {
    member.borrowBook(book);
  }

  DateTime? get returnDate => _returnDate;

  void returnBook() {
    _returnDate = DateTime.now();
    member.returnBook(book);
  }

  Duration get loanDuration => (_returnDate ?? DateTime.now()).difference(loanDate);
}

class Library {
  final List<Book> _books = [];
  final List<Member> _members = [];
  final List<Loan> _loans = [];
  final List<Author> _authors = [];

  List<Book> get books => List.unmodifiable(_books);
  List<Member> get members => List.unmodifiable(_members);
  List<Loan> get activeLoans => _loans.where((loan) => loan.returnDate == null).toList();

  void addBook(Book book, [Author? author]) {
    _books.add(book);
    author?.addPublishedBook(book);
    print("Книга добавлена: $book");
  }

  void addMember(Member member) {
    _members.add(member);
    print("Член библиотеки зарегистрирован: ${member.fullName}");
  }

  void addAuthor(Author author) {
    _authors.add(author);
    print("Автор добавлен: ${author.fullName}");
  }

  void loanBook(Member member, Book book) {
    if (!book.isAvailable) {
      throw Exception("Книга недоступна для выдачи");
    }
    if (!_members.contains(member)) {
      throw Exception("Член библиотеки не зарегистрирован");
    }
    _loans.add(Loan(member, book, DateTime.now()));
    print("Книга '${book.title}' выдана ${member.fullName}");
  }

  void returnBook(Book book) {
    final loan = _loans.firstWhere(
      (l) => l.book == book && l.returnDate == null,
      orElse: () => throw Exception("Книга не находится в выдаче"),
    );
    loan.returnBook();
    print("Книга '${book.title}' возвращена ${loan.member.fullName}");
  }

  void displayAllBooks() {
    if (_books.isEmpty) {
      print("В библиотеке нет книг");
      return;
    }
    print("\nКниги в библиотеке:");
    _books.forEach((book) {
      final status = book.isAvailable ? "Доступна" : "На выдаче";
      print("$book - Статус: $status");
    });
  }

  void displayAllMembers() {
    if (_members.isEmpty) {
      print("Нет зарегистрированных членов");
      return;
    }
    print("\nЧлены библиотеки:");
    _members.forEach((member) => member.displayInfo());
  }

  void displayAllAuthors() {
    if (_authors.isEmpty) {
      print("Нет зарегистрированных авторов");
      return;
    }
    print("\nАвторы:");
    _authors.forEach((author) => author.displayInfo());
  }

  List<Book> searchBooks(String query) {
    return _books.where((book) =>
        book.title.toLowerCase().contains(query.toLowerCase()) ||
        book.author.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<Member> searchMembers(String query) {
    return _members.where((member) =>
        member.fullName.toLowerCase().contains(query.toLowerCase()) ||
        member.email.toLowerCase().contains(query.toLowerCase())).toList();
  }
}

class LibraryApp {
  final Library _library = Library();

  void run() {
    print("Добро пожаловать в систему управления библиотекой");

    while (true) {
      _displayMenu();
      final choice = _getUserChoice();

      switch (choice) {
        case 1:
          _addBook();
          break;
        case 2:
          _addMember();
          break;
        case 3:
          _addAuthor();
          break;
        case 4:
          _loanBook();
          break;
        case 5:
          _returnBook();
          break;
        case 6:
          _library.displayAllBooks();
          break;
        case 7:
          _library.displayAllMembers();
          break;
        case 8:
          _library.displayAllAuthors();
          break;
        case 9:
          _searchBooks();
          break;
        case 10:
          _searchMembers();
          break;
        case 0:
          print("Выход из системы...");
          return;
        default:
          print("Неверный ввод. Пожалуйста, попробуйте снова.");
      }
    }
  }

  void _displayMenu() {
    print("\n--- Система управления библиотекой ---");
    print("1. Добавить книгу");
    print("2. Добавить члена библиотеки");
    print("3. Добавить автора");
    print("4. Выдать книгу");
    print("5. Вернуть книгу");
    print("6. Показать все книги");
    print("7. Показать всех членов");
    print("8. Показать всех авторов");
    print("9. Поиск книг");
    print("10. Поиск членов");
    print("0. Выход");
    stdout.write("Введите ваш выбор: ");
  }

  int _getUserChoice() {
    try {
      return int.parse(stdin.readLineSync() ?? '');
    } catch (e) {
      return -1;
    }
  }

  void _addBook() {
    print("\nДобавление новой книги");
    stdout.write("Название: ");
    final title = stdin.readLineSync() ?? '';
    stdout.write("Автор: ");
    final author = stdin.readLineSync() ?? '';
    stdout.write("ISBN: ");
    final isbn = stdin.readLineSync() ?? '';

    stdout.write("Автор уже есть в системе? (y/n): ");
    final authorInSystem = stdin.readLineSync()?.toLowerCase() == 'y';

    Author? bookAuthor;
    if (authorInSystem) {
      stdout.write("Введите полное имя автора: ");
      final authorName = stdin.readLineSync() ?? '';
      bookAuthor = _library._authors.firstWhere(
        (a) => a.fullName == authorName,
        orElse: () {
          print("Автор не найден. Создание нового автора.");
          return _createAuthor(authorName);
        },
      );
    } else {
      bookAuthor = _createAuthor(author);
    }

    final book = Book(title, author, isbn);
    _library.addBook(book, bookAuthor);
  }

  Author _createAuthor(String authorName) {
    stdout.write("Email автора: ");
    final email = stdin.readLineSync() ?? '';
    stdout.write("Телефон автора: ");
    final phone = stdin.readLineSync() ?? '';
    stdout.write("Биография автора: ");
    final bio = stdin.readLineSync() ?? '';

    final author = Author(authorName, email, phone, bio);
    _library.addAuthor(author);
    return author;
  }

  void _addMember() {
    print("\nРегистрация нового члена библиотеки");
    stdout.write("Полное имя: ");
    final name = stdin.readLineSync() ?? '';
    stdout.write("Email: ");
    final email = stdin.readLineSync() ?? '';
    stdout.write("Телефон: ");
    final phone = stdin.readLineSync() ?? '';

    final member = Member(name, email, phone, DateTime.now());
    _library.addMember(member);
  }

  void _addAuthor() {
    print("\nДобавление нового автора");
    stdout.write("Полное имя: ");
    final name = stdin.readLineSync() ?? '';
    stdout.write("Email: ");
    final email = stdin.readLineSync() ?? '';
    stdout.write("Телефон: ");
    final phone = stdin.readLineSync() ?? '';
    stdout.write("Биография: ");
    final bio = stdin.readLineSync() ?? '';

    final author = Author(name, email, phone, bio);
    _library.addAuthor(author);
  }

  void _loanBook() {
    if (_library._books.isEmpty) {
      print("Нет доступных книг для выдачи");
      return;
    }
    if (_library._members.isEmpty) {
      print("Нет зарегистрированных членов");
      return;
    }

    print("\nДоступные книги:");
    _library._books.where((book) => book.isAvailable).forEach(print);

    print("\nЗарегистрированные члены:");
    _library._members.forEach((m) => print(m.fullName));

    stdout.write("\nВведите название книги для выдачи: ");
    final title = stdin.readLineSync() ?? '';
    final book = _library._books.firstWhere(
      (b) => b.title == title && b.isAvailable,
      orElse: () => throw Exception("Книга не найдена или недоступна"),
    );

    stdout.write("Введите имя члена библиотеки: ");
    final memberName = stdin.readLineSync() ?? '';
    final member = _library._members.firstWhere(
      (m) => m.fullName == memberName,
      orElse: () => throw Exception("Член библиотеки не найден"),
    );

    _library.loanBook(member, book);
  }

  void _returnBook() {
    final activeLoans = _library.activeLoans;
    if (activeLoans.isEmpty) {
      print("Нет книг на выдаче");
      return;
    }

    print("\nКниги на выдаче:");
    activeLoans.forEach((loan) {
      print("${loan.book.title} (Выдано: ${loan.member.fullName})");
    });

    stdout.write("\nВведите название книги для возврата: ");
    final title = stdin.readLineSync() ?? '';
    final book = _library._books.firstWhere(
      (b) => b.title == title && !b.isAvailable,
      orElse: () => throw Exception("Книга не найдена или не на выдаче"),
    );

    _library.returnBook(book);
  }

  void _searchBooks() {
    stdout.write("\nВведите запрос для поиска: ");
    final query = stdin.readLineSync() ?? '';
    final results = _library.searchBooks(query);
    
    if (results.isEmpty) {
      print("Книги по запросу '$query' не найдены");
    } else {
      print("Результаты поиска:");
      results.forEach(print);
    }
  }

  void _searchMembers() {
    stdout.write("\nВведите запрос для поиска: ");
    final query = stdin.readLineSync() ?? '';
    final results = _library.searchMembers(query);
    
    if (results.isEmpty) {
      print("Члены библиотеки по запросу '$query' не найдены");
    } else {
      print("Результаты поиска:");
      results.forEach((member) => print(member.fullName));
    }
  }
}

void main() {
  LibraryApp().run();
}
