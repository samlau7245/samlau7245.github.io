---
title: Dart 知识学习
layout: post
categories:
 - dart
---

## 变量

* `final`: 变量的值只能被设置一次。实例变量可以是 final 类型但不能是 const 类型。
* `const`: 变量在编译时就已经固定。类级别中使用：`static const`。

```dart
int lineCount; // 未初始化的变量默认值是 null。即使变量是数字 类型默认值也是 null，因为在 Dart 中一切都是对象，数字类型 也不例外。
var name = 'Bob'; // 没有使用指定类型的方式来定义变量
String name = 'Bob';

// Final
final name = 'Bob';
name = 'Alice'; // Error: 一个 final 变量只能被设置一次。

// const
const bar = 1000000;
```

## 内建类型

* `Number`
	* `int`：从 Dart 2.1 开始，必要的时候`int`字面量会自动转换成`double`类型
	* `double`：
* `String` : 是一组 UTF-16 单元序列,字符串通过单引号或者双引号创建。
	* 内嵌:`${expression}`、单表达式`{}`可省略。
	* `==`运算符用来测试两个对象是否相等。
	* `+`运算符来把多个字符串连接为一个。
	* 字符串含引号：连续三个单引号、连续三个双引号、使用`r`前缀。
* `bool` : `true`、`false`
* `List` : (也被称为 Array)
* `Set` : 是一个元素唯一且无需的集合。
* `Map` : 用来关联 keys 和 values 的对象
* `Rune` : 表示字符串中的 UTF-32 编码字符(用于在字符串中表示 Unicode 字符)
* `Symbol` : 表示 Dart 程序中声明的运算符或者标识符。

```dart
// int
var x = 1;
var hex = 0xDEADBEEF;

// double
var y = 1.1;
var exponents = 1.42e5;

// String -> int
var one = int.parse('1');

// String -> double
var onePointOne = double.parse('1.1');

// int -> String
String oneAsString = 1.toString();

// double -> String
String piAsString = 3.14159.toStringAsFixed(2);

var s = 'string interpolation';
var s1 = '${s.toUpperCase()} is very handy!';

const aConstNum = 0;
var s = '$aConstNum is very handy!';

// List
var list = [1, 2, 3];
list.length

// Set
var halogens = {'fluorine', 'chlorine', 'bromine', 'iodine', 'astatine'};

// Map
var gifts = {
  // Key:    Value
  'first': 'partridge',
  'second': 'turtledoves',
  'fifth': 'golden rings'
};

var nobleGases = {
  2: 'helium',
  10: 'neon',
  18: 'argon',
};

var gifts = Map();
gifts['first'] = 'partridge';
gifts['second'] = 'turtledoves';
gifts['fifth'] = 'golden rings';
gifts.length

var nobleGases = Map();
nobleGases[2] = 'helium';
nobleGases[10] = 'neon';
nobleGases[18] = 'argon';
```

## 函数

函数是一个类型为`Function`的对象。这意味着函数可以被赋值给变量或者作为参数传递给其他函数。也可以把`Dart`类的实例当做方法来调用。

如果函数中只有一句表达式，可以使用简写语法：`=> expr`，它是`{ return expr; }`的简写。

```dart
bool isNoble(int atomicNumber) {
  return _nobleGases[atomicNumber] != null;
}

bool isNoble(int atomicNumber) => _nobleGases[atomicNumber] != null;
```

### 可选参数

#### 命名可选参数

`void enableFlags({bool bold, bool hidden}) {
}`

```dart
// 声明
void enableFlags({bool bold, bool hidden}) {
}

// @required:注释表明参数 hidden 为必须参数
void enableFlags({bool bold, @required bool hidden}) {
}

// 调用
enableFlags(bold: false);
enableFlags(bold: false,hidden: false);
```

#### 位置可选参数
位置可选参数 : 将参数放到`[]`中来标记参数是可选的。

```dart
// 声明
String say(String from, String msg, [String device]) {
  var result = '$from says $msg';
  if (device != null) {
    result = '$result with a $device';
  }
  return result;
}

// 调用
say('Bob', 'Howdy')
say('Bob', 'Howdy', 'smoke signal')
```

#### 默认参数值
使用`=`来定义可选参数的默认值。如果没有提供默认值，则默认值为`null`。

```dart
void enableFlags({bool bold = false, bool hidden = false}) {
}
String say(String from, String msg,[String device = 'carrier pigeon', String mood]) {
}
void doStuff({List<int> list = const [1, 2, 3],
    Map<String, String> gifts = const {
      'first': 'paper',
      'second': 'cotton',
      'third': 'leather'
    }}) {
  print('list:  $list');
  print('gifts: $gifts');
}
```

### main() 函数
任何应用都必须有一个顶级 `main()` 函数，作为应用服务的入口,参数为一个可选的`List<String>` 。可以通过[args library](https://pub.dev/packages/args)定义和解析命令行参数。

```dart
void main() {
}

void main(List<String> arguments) {
}
```

### 匿名函数

匿名函数：没有名字的函数，有时候也被称为`lambda`或者`closure`。匿名函数可以赋值到一个变量中。

```dart
([[Type] param1[, …]]) { // 在()可以定义一些参数或者可选参数，参数用逗号分隔。
  codeBlock; 
};
```

下面例子中定义了一个包含一个无类型参数 item 的匿名函数。 list 中的每个元素都会调用这个函数，打印元素位置和值的字符串。

```dart
var list = ['apples', 'bananas', 'oranges'];
list.forEach((item) {
  print('${list.indexOf(item)}: $item');
});

list.forEach((item) => print('${list.indexOf(item)}: $item'));

// 0: apples
// 1: bananas
// 2: oranges
```

把匿名函数赋值给变量：

```dart
var loudify = (msg) => '!!! ${msg.toUpperCase()} !!!';
assert(loudify('hello') == '!!! HELLO !!!');
```

### 闭包
`闭包`: 就是一个函数对象，即使函数对象的调用在它原始作用域之外， 依然能够访问在它词法作用域内的变量。

```dart
/// 返回一个函数，返回的函数参数与 [addBy] 相加。
Function makeAdder(num addBy) {
  return (num i) => addBy + i;
}

void main() {
  // 创建一个加 2 的函数。
  var add2 = makeAdder(2);

  // 创建一个加 4 的函数。
  var add4 = makeAdder(4);

  assert(add2(3) == 5);
  assert(add4(3) == 7);
}
```

### 返回值

所有函数都会返回一个值。 如果没有明确指定返回值， 函数体会被隐式的添加`return null;`语句。

## 运算符

### 类型判定运算符

* `as` : 用于在运行时处理类型检查,会将对象强制转换为特定类型。
* `is` : 用于在运行时处理类型检查,类型判定。
* `is!` : 用于在运行时处理类型检查,类型判定。



```dart
if (emp is Person) {emp.firstName = 'Bob';}

(emp as Person).firstName = 'Bob';
```

### 赋值运算符

* `??=` : 只有当被赋值的变量为 null 时才会赋值给它。

```dart
b ??= value; // 如果b为空时，将变量赋值给b，否则，b的值保持不变。
```

### 条件表达式

* `condition ? expr1 : expr2`：
* `expr1 ?? expr2`：如果 expr1 是 non-null， 返回 expr1 的值； 否则, 执行并返回 expr2 的值。

### 级联运算符 (..)
`级联运算符 (..)` 可以实现对同一个对像进行一系列的操作。 除了调用函数，还可以访问同一对象上的字段属性。 这通常可以节省创建临时变量的步骤， 同时编写出更流畅的代码。

> `级联运算符 (..)`不能在`void`对象上创建级联操作。

```dart
querySelector('#confirm') // 获取对象。
  ..text = 'Confirm' // 调用成员变量。
  ..classes.add('important')
  ..onClick.listen((e) => window.alert('Confirmed!'));

// 等价于
var button = querySelector('#confirm');
button.text = 'Confirm';
button.classes.add('important');
button.onClick.listen((e) => window.alert('Confirmed!'));
```

## 控制流程语句

* `while`:使用`break`停止程序循环。使用`continue`跳转到下一次迭代。
* `assert`: 如果`assert`语句中的布尔条件为`false`， 那么正常的程序执行流程会被中断。 

```dart
if (isRaining()) {
} else if (isSnowing()) {
} else {
}

for (var i = 0; i < 5; i++) {
}

while (boolValue) {
}

do {
} while (boolValue);

while (true) {
  if (shutDownRequested()) break;
  processIncomingRequests();
}

switch (command) {
  case 'CLOSED':
    executeClosed();
    break;
  case 'PENDING':
    executePending();
    break;
  default:
    executeUnknown();
}
```

## 异常

```dart
// 抛异常
throw FormatException('Expected at least 1 section');
// 抛异常
throw 'Out of llamas!';

// 抛异常
try {
  breedMoreLlamas();
} on OutOfLlamasException {
  // 一个特殊的异常
  buyMoreLlamas();
} on Exception catch (e) {
  // 其他任何异常
  print('Unknown exception: $e');
} catch (e) {
  // 没有指定的类型，处理所有异常
  print('Something really unknown: $e');
} finally {
  cleanLlamaStalls(); // Then clean up.
}
```

## 类

`Dart`是一种基于类和`mixin`继承机制的面向对象的语言。每个对象都是一个类的实例，所有的类都继承于`Object`。

* 使用`.`来引用实例对象的变量和方法。
* 使用`?.`来代替`.`，可以避免因为左边对象可能为`null`。

```dart
var p = Point(2, 2);
p?.y = 4; // 如果 p 为 non-null，设置它变量 y 的值为 4。
```

### 实例变量
* 未初始化实例变量的默认人值为`null`。
* 所有实例变量都生成隐式`getter`方法。 

```dart
class Point {
  num x; // 声明示例变量 x，初始值为 null 。
  num y; // 声明示例变量 y，初始值为 null 。
  num z = 0; // 声明示例变量 z，初始值为 0 。
}
void main() {
  var point = Point();
  point.x = 4; // Use the setter method for x.
  assert(point.x == 4); // Use the getter method for x.
}
```

### 构造函数
* 在没有声明构造函数的情况下，`Dart`会提供一个默认的构造函数。
* 子类不会继承父类的构造函数。

```dart
class Point {
  num x, y;

  Point(num x, num y) {
    this.x = x;
    this.y = y;
  }
}

// 或者
class Point {
  num x, y;
  Point(this.x, this.y);
}
```

命名构造函数 : 使用命名构造函数可为一个类实现多个构造函数， 也可以使用命名构造函数来更清晰的表明函数意图。

```dart
class Point {
  num x, y;

  Point(this.x, this.y);

  // 命名构造函数
  Point.origin() {
    x = 0;
    y = 0;
  }
}
```

调用父类非默认构造函数:

```dart
class Person {
  String firstName;

  Person.fromJson(Map data) {
    print('in Person');
  }
}

class Employee extends Person {
  // Person does not have a default constructor;
  // you must call super.fromJson(data).
  Employee.fromJson(Map data) : super.fromJson(data) {
    print('in Employee');
  }
}

main() {
  var emp = new Employee.fromJson({});

  // Prints:
  // in Person
  // in Employee
  if (emp is Person) {
    // Type check
    emp.firstName = 'Bob';
  }
  (emp as Person).firstName = 'Bob';
}
```

## 参考资料

* [Dart 编程语言概览](https://www.dartcn.com/guides/language/language-tour)
* [DartPad](https://dartpad.cn)






















































































