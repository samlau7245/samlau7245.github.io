---
title: Flutter 矩阵变换(Matrix4)
layout: post
categories:
 - dart
---

## Matrix4

```dart
// 默认4*4的四阶矩阵
factory Matrix4(
 double arg0,
 double arg1,
 double arg2,
 double arg3,
 double arg4,
 double arg5,
 double arg6,
 double arg7,
 double arg8,
 double arg9,
 double arg10,
 double arg11,
 double arg12,
 double arg13,
 double arg14,
 double arg15
);
```

### Matrix4.zero()

> 会初始化一个所有参数值为 0 的空矩阵。可以在此基础上进行其他操作：

```dart
transform: Matrix4.zero(),
transform: Matrix4.zero()..setIdentity(),
```

### Matrix4.identity

```dart
factory Matrix4.identity() => new Matrix4.zero()..setIdentity();

void setIdentity() {
  _m4storage[0] = 1.0;
  _m4storage[1] = 0.0;
  _m4storage[2] = 0.0;
  _m4storage[3] = 0.0;
  _m4storage[4] = 0.0;
  _m4storage[5] = 1.0;
  _m4storage[6] = 0.0;
  _m4storage[7] = 0.0;
  _m4storage[8] = 0.0;
  _m4storage[9] = 0.0;
  _m4storage[10] = 1.0;
  _m4storage[11] = 0.0;
  _m4storage[12] = 0.0;
  _m4storage[13] = 0.0;
  _m4storage[14] = 0.0;
  _m4storage[15] = 1.0;
}
```

方法内部先调用`Matrix4.zero()` 创建一个空矩阵，然后调用 `setIdentity()`把四阶矩阵的值进行初始化。可以在此基础上进行其他的操作：

```dart
transform: Matrix4.identity(),
transform: Matrix4.identity()..rotateZ(pi / 4),
```
### Matrix4.fromList

```
factory Matrix4.fromList(List<double> values);
```
它是从一个`List`中获取矩阵的值，然后方法内部通过创建`Matrix4.zero()`空矩阵，然后再进行逐一赋值。

```dart
List<double> list = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0];
transform: Matrix4.fromList(list),
```

### Matrix4.copy

> 拷贝一个已有的 Matrix4


### Matrix4.columns

> 由四个4D列向量组成4X4矩阵。

```dart
factory Matrix4.columns(Vector4 arg0, Vector4 arg1, Vector4 arg2, Vector4 arg3) => new Matrix4.zero()..setColumns(arg0, arg1, arg2, arg3);

factory Vector4(double x, double y, double z, double w);
```

### Matirx4.inverted

> 逆向矩阵，与原 Matrix4 矩阵相反(矩阵坐标沿着左对角线对称)

```dart
factory Matrix4.inverted(Matrix4 other);
```

### Matrix4.outer

> 两个四阶矩阵的合并乘积,，注意两个四阶矩阵的先后顺序决定最终合并后的矩阵数组

```dart
factory Matrix4.outer(Vector4 u, Vector4 v);
```

## 缩放(Scale)

### Matrix4.diagonal3

> 通过 Vector3 设置缩放矩阵

```dart
factory Matrix4.diagonal3(Vector3 scale);

// 在 x y z 轴方向上的缩放。
factory Vector3(double x, double y, double z);
factory Vector3.array(List<double> array, [int offset = 0]);
```

```dart
transform: Matrix4.diagonal3(v.Vector3(2.0, 1.0, 1.0)),
transform: Matrix4.diagonal3(v.Vector3.array([2.0, 2.0, 2.0])),
```

### Matrix4.diagonal3Values

> 缩放

```dart
factory Matrix4.diagonal3Values(double x, double y, double z) =>
    new Matrix4.zero()
      .._m4storage[15] = 1.0
      .._m4storage[10] = z
      .._m4storage[5] = y
      .._m4storage[0] = x;

// 结果：
factory Matrix4(
 double arg0,  -> x
 double arg1,  -> 0
 double arg2,  -> 0
 double arg3,  -> 0

 double arg4,  -> 0
 double arg5,  -> y
 double arg6,  -> 0
 double arg7,  -> 0

 double arg8,  -> 0
 double arg9,  -> 0
 double arg10, -> z 
 double arg11, -> 0 

 double arg12, -> 0 
 double arg13, -> 0 
 double arg14, -> 0 
 double arg15  -> 1.0
);      
```

## 平移(translation)

### Matrix4.translation

> 通过`Vector3`构造方法的各参数设置矩阵平移量；水平向右为 x 轴正向，竖直向下为 y 轴正向。

```dart
factory Matrix4.translation(Vector3 translation) => new Matrix4.zero()
 ..setIdentity()
 ..setTranslation(translation);

void setTranslation(Vector3 t) {
  final Float64List tStorage = t._v3storage;
  final double z = tStorage[2];
  final double y = tStorage[1];
  final double x = tStorage[0];
  _m4storage[14] = z;
  _m4storage[13] = y;
  _m4storage[12] = x;
} 

// 结果类似于：
void setIdentity() {
  _m4storage[0] = 1.0;
  _m4storage[1] = 0.0;
  _m4storage[2] = 0.0;
  _m4storage[3] = 0.0;

  _m4storage[4] = 0.0;
  _m4storage[5] = 1.0;
  _m4storage[6] = 0.0;
  _m4storage[7] = 0.0;

  _m4storage[8] = 0.0;
  _m4storage[9] = 0.0;
  _m4storage[10] = 1.0;
  _m4storage[11] = 0.0;

  _m4storage[12] = x;
  _m4storage[13] = y;
  _m4storage[14] = z;
  _m4storage[15] = 1.0;
}
```

### Matrix4.translationValues

> 直接传 x、y、z 来进行平移。

```dart
factory Matrix4.translationValues(double x, double y, double z) =>
  new Matrix4.zero()
    ..setIdentity()
    ..setTranslationRaw(x, y, z);


void setTranslationRaw(double x, double y, double z) {
  _m4storage[14] = z;
  _m4storage[13] = y;
  _m4storage[12] = x;
}
```

## 旋转(Rotation)
















