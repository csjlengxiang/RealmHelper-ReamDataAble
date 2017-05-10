#### 此demo抛砖了一种封装RealmSwift的方法
##### 我们常常遇到的问题（RealmSwift常用的坑）
```
1. Realm model必须继承Object，即必须使用Class，这里与大伙儿推荐使用struct + procotol方式相悖
2. Realm model被add 到数据库后（或者说从数据库里取出），无法跨线程调用
3. 多个线程有多个Realm快照，Realm不能跨线程
4. 动态性，由于数据是底层数据的动态表现，于是作为数据的句柄，操作了数据，其他句柄作为动态数据的表现则变化
```
##### 解决方式
```
针对数据的动态性，添加 RealmDataAble 和 basicDataAble 用于 realm model 到 basic model的转换，方式倒是比较简单采用了HandyJSON
```
如下代码
```
protocol RealmDataAble: HandyJSON {
    associatedtype realmDataType
    var realmData: realmDataType? { get }
}

protocol BasicDataAble: class, HandyJSON {
    associatedtype basicDataType
    var basicData: basicDataType? { get }
}

extension RealmDataAble where Self.realmDataType: BasicDataAble, Self.realmDataType: Object {
    var realmData: realmDataType? {
        return realmDataType.deserialize(from: self.toJSONString())
    }
}

extension BasicDataAble where Self: Object, Self.basicDataType: RealmDataAble {
    var basicData: basicDataType? {
        return basicDataType.deserialize(from: self.toJSONString())
    }
}
```

这样，我们定义一个model时候，是这样写
```
class PersonModel: Object, BasicDataAble {
    typealias basicDataType = Person

    dynamic var key = "key"
    dynamic var name = "csj"
    dynamic var age = 2
    
    override static func primaryKey() -> String? {
        return "key"
    }
}

struct Person: RealmDataAble {
    typealias realmDataType = PersonModel
    
    var key = "key"
    var name = "csj"
    var age = 2
}
```
有了模型转换，接下来就可以对struct Person（RealmDataAblez）数据做默认扩展了，比如：
```
extension RealmDataAble where Self.realmDataType: BasicDataAble, Self.realmDataType: Object {
    
    var realmData: realmDataType? {
        return realmDataType.deserialize(from: self.toJSONString())
    }
    
    // 普通数据增删改查...待添加
    func add() {
        guard let realmData = self.realmData else {
            return
        }
        RealmHelper.add(object: realmData)
    }
    
    // 普通数据获取
    static func select(predicate: NSPredicate, clouse: @escaping ([Self]) -> Void) {
        
        let newClouse: (Results<Self.realmDataType>) -> Void = { results in
            var ret: [Self] = []
            for result in results {
                ret.append(result.basicData as! Self)
            }
            clouse(ret)
        }
        RealmHelper.select(type: Self.realmDataType.self, predicate: predicate, clouse: newClouse)
    }
}
```


