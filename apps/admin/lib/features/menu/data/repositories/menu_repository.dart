import '../models/category_model.dart';
import '../models/food_model.dart';

class MenuRepository {
  Future<List<CategoryModel>> fetchCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: mock data
    return [
      const CategoryModel(id: 1, name: 'Cơm', description: 'Các món cơm'),
      const CategoryModel(id: 2, name: 'Bún & Phở', description: 'Bún, phở, mì'),
      const CategoryModel(id: 3, name: 'Đồ uống', description: 'Nước, trà, cà phê'),
      const CategoryModel(id: 4, name: 'Tráng miệng', description: 'Chè, bánh, kem'),
    ];
  }

  Future<List<FoodModel>> fetchFoods() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: mock data
    return [
      FoodModel(
        id: 1, name: 'Cơm sườn nướng', price: 65000,
        categoryId: 1, categoryName: 'Cơm',
        description: 'Sườn nướng mật ong, cơm trắng dẻo',
        imageUrl: 'https://images.unsplash.com/photo-1628294895950-9805252327bc?w=400&q=60',
        isAvailable: true,
      ),
      FoodModel(
        id: 2, name: 'Cơm gà xối mỡ', price: 60000,
        categoryId: 1, categoryName: 'Cơm',
        description: 'Gà da giòn, cơm thơm, nước mắm ớt',
        imageUrl: 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=400&q=60',
        isAvailable: true,
      ),
      FoodModel(
        id: 3, name: 'Cơm tấm đặc biệt', price: 70000,
        categoryId: 1, categoryName: 'Cơm',
        description: 'Sườn bì chả, trứng ốp la',
        imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400&q=60',
        isAvailable: true,
      ),
      FoodModel(
        id: 4, name: 'Phở bò tái nạm', price: 65000,
        categoryId: 2, categoryName: 'Bún & Phở',
        description: 'Phở tươi, thịt bò tái, nạm mềm',
        imageUrl: 'https://images.unsplash.com/photo-1617093727343-374698b1b08d?w=400&q=60',
        isAvailable: true,
      ),
      FoodModel(
        id: 5, name: 'Bún bò Huế', price: 60000,
        categoryId: 2, categoryName: 'Bún & Phở',
        description: 'Chuẩn vị Huế, chả cua, mắm ruốc',
        isAvailable: false,
      ),
      FoodModel(
        id: 6, name: 'Trà đào cam sả', price: 35000,
        categoryId: 3, categoryName: 'Đồ uống',
        description: 'Trà tươi, đào mật, cam tươi',
        isAvailable: true,
      ),
      FoodModel(
        id: 7, name: 'Cà phê sữa đá', price: 25000,
        categoryId: 3, categoryName: 'Đồ uống',
        description: 'Phin Việt Nam truyền thống',
        isAvailable: true,
      ),
      FoodModel(
        id: 8, name: 'Chè thái', price: 30000,
        categoryId: 4, categoryName: 'Tráng miệng',
        description: 'Thạch, trân châu, nước cốt dừa',
        isAvailable: true,
      ),
      FoodModel(
        id: 9, name: 'Kem tươi matcha', price: 45000,
        categoryId: 4, categoryName: 'Tráng miệng',
        description: 'Matcha Nhật, kem tươi Hokkaido',
        isAvailable: false,
      ),
    ];
  }
}
