import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class ProductManager extends StatefulWidget {
  @override
  _ProductManagerState createState() => _ProductManagerState();
}

class _ProductManagerState extends State<ProductManager> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _refreshProductList();
  }

  void _refreshProductList() async {
    final data = await _dbHelper.getProducts();
    setState(() {
      _products = data;
    });
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingProduct = _products.firstWhere((element) => element['id'] == id);
      _nameController.text = existingProduct['name'];
      _descriptionController.text = existingProduct['description'];
      _priceController.text = existingProduct['price'].toString();
      _selectedProductId = id;
    } else {
      _nameController.text = '';
      _descriptionController.text = '';
      _priceController.text = '';
      _selectedProductId = null;
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _priceController.text.isEmpty) {
                  return;
                }

                Map<String, dynamic> product = {
                  'name': _nameController.text,
                  'description': _descriptionController.text,
                  'price': double.parse(_priceController.text),
                };

                if (_selectedProductId == null) {
                  await _dbHelper.insertProduct(product);
                } else {
                  product['id'] = _selectedProductId;
                  await _dbHelper.updateProduct(product);
                }

                _refreshProductList();
                Navigator.of(context).pop();
              },
              child: Text(_selectedProductId == null ? 'Add Product' : 'Update Product'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(int id) async {
    await _dbHelper.deleteProduct(id);
    _refreshProductList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Manager'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(_products[index]['name']),
                    subtitle: Text(
                        '${_products[index]['description']}\nPrice: \$${_products[index]['price']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showForm(_products[index]['id']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteProduct(_products[index]['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}