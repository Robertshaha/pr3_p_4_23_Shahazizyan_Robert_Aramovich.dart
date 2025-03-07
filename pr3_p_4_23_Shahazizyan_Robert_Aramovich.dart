import 'dart:io';

class Book {
  String title;
  String author;
  String isbn;
  bool isAvailable;

  Book(this.title, this.author,this.isbn): isAvailable = true;
}

class Member {
  String fullName;
  String email;
  String phoneNumber;

  Member(this.fullName, this.email, this.phoneNumber);
}

class Author {
  String fullName;
  String email;
  String phoneNumber;
  String status;

  Author(this.fullName, this.email, this.phoneNumber, this.status);
}

class Loan {
  Member member;
  Book book;
  DateTime loanDate;
  DateTime? returnDate;

  Loan(this.member, this.book, this.loanDate);
}

class Library {
  List<Book> books = [];
  List<Member> members = [];
  List<Loan> loans = [];

  void addBook(Book book) {
    books.add(book);
    print("Книга '${book.title}' добавлена в библиотеку.");
  }

  void addMember(Member member) {
    members.add(member);
    print("Член библиотеки '${member.fullName}' добавлен.");
  }

  void loanBook(Member member, Book book) {
    if (loans.any((loan) => loan.book == book && loan.returnDate == null)) {
      print("Ошибка: книга '${book.title}' уже выдана.");
      return;
    }
    Loan loan = Loan(member, book, DateTime.now());
    loans.add(loan);
    print("Книга '${book.title}' выдана члену библиотеки '${member.fullName}'.");
  }

  void returnBook(Book book) {
    for (var loan in loans) {
      if (loan.book == book && loan.returnDate == null) {
        loan.returnDate = DateTime.now();
        print("Книга '${book.title}' возвращена.");
        return;
      }
    }
    print("Ошибка: книга '${book.title}' не была выдана.");
  }

  void listBooks() {
    if (books.isEmpty) {
      print("В библиотеке нет книг.");
      return;
    }
    for (var book in books) {
      bool isLoaned = loans.any((loan) => loan.book == book && loan.returnDate == null);
      String status = isLoaned ? "выдана" : "доступна";
      print("Книга: '${book.title}', Автор: '${book.author}', Статус: $status");
    }
  }

  void listMembers() {
    if (members.isEmpty) {
      print("В библиотеке нет членов.");
      return;
    }
    for (var member in members) {
      print("Член библиотеки: '${member.fullName}', Email: '${member.email}', Телефон: '${member.phoneNumber}'");
    }
  }

  List<Book> searchBooks(String query) {
    return books.where((book) => book.title.contains(query) || book.author.contains(query)).toList();
  }
}

void main() {
  Library library = Library();

  while (true) {
    print("\n--- Меню библиотеки ---");
    print("1. Добавить книгу");
    print("2. Просмотреть книги");
    print("3. Добавить члена библиотеки");
    print("4. Выдать книгу");
    print("5. Вернуть книгу");
    print("6. Просмотреть членов библиотеки");
    print("7. Поиск книги");
    print("0. Выход");

    stdout.write("Выберите опцию: ");
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        stdout.write("Введите название книги: ");
        String title = stdin.readLineSync() ?? '';
        stdout.write("Введите автора книги: ");
        String author = stdin.readLineSync() ?? '';
        stdout.write("Введите isbn книги: ");
        String isbn = stdin.readLineSync() ?? '';
        library.addBook(Book(title, author,));
        break;

      case '2':
        library.listBooks();
        break;

      case '3':
        stdout.write("Введите ФИО члена библиотеки: ");
        String fullName = stdin.readLineSync() ?? '';
        stdout.write("Введите email: ");
        String email = stdin.readLineSync() ?? '';
        stdout.write("Введите номер телефона: ");
        String phoneNumber = stdin.readLineSync() ?? '';
        library.addMember(Member(fullName, email, phoneNumber));
        break;

      case '4':
        library.listMembers();
        stdout.write("Введите ФИО члена, который берет книгу: ");
        String memberName = stdin.readLineSync() ?? '';
        Member? member;
        for (var m in library.members) {
          if (m.fullName == memberName) {
            member = m;
            break;
          }
        }
        if (member == null) {
          print("Член с таким ФИО не найден.");
          break;
        }
        
        stdout.write("Введите название книги, которую хотите выдать: ");
        String bookTitle = stdin.readLineSync() ?? '';
        Book? book;
        for (var b in library.books) {
          if (b.title == bookTitle) {
            book = b;
            break;
          }
        }
        if (book == null) {
          print("Книга с таким названием не найдена.");
          break;
        }
        library.loanBook(member, book);
        break;

      case '5':
        stdout.write("Введите название книги для возврата: ");
        String returnTitle = stdin.readLineSync() ?? '';
        Book? returnBook;
        for (var b in library.books) {
          if (b.title == returnTitle) {
            returnBook = b;
            break;
          }
        }
        if (returnBook == null) {
          print("Книга с таким названием не найдена.");
          break;
        }
        library.returnBook(returnBook);
        break;

      case '6':
        library.listMembers();
        break;

      case '7':
        stdout.write("Введите название или автора для поиска: ");
        String query = stdin.readLineSync() ?? '';
        var searchResults = library.searchBooks(query);
        print("Результаты поиска:");
        for (var book in searchResults) {
          print("Книга найдена: '${book.title}' автор '${book.author}'");
        }
        break;

      case '0':
        print("Выход из программы...");
        return;

      default:
        print("Неверный ввод. Пожалуйста, попробуйте снова.");
    }
  }
}
