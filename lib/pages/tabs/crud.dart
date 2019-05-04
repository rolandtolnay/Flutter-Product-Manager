import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../model/product.dart';
import '../../scoped_models/main.dart';

class ProductCrudTab extends StatefulWidget {
  const ProductCrudTab({Key key}) : super(key: key);

  @override
  _ProductCrudTabState createState() => _ProductCrudTabState();
}

class _ProductCrudTabState extends State<ProductCrudTab> {
  //
  final Map<String, dynamic> _formData = {'imageUrl': 'assets/food.jpg'};
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //
    final deviceWidth = MediaQuery.of(context).size.width;
    final targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Container(
        margin: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ScopedModelDescendant<MainModel>(
            builder: (_, __, MainModel model) {
              return ListView(
                padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
                children: <Widget>[
                  _buildTitleTextField(model.selectedProduct),
                  const SizedBox(height: 8.0),
                  _buildDescriptionTextField(model.selectedProduct),
                  const SizedBox(height: 8.0),
                  _buildPriceTextField(model.selectedProduct),
                  const SizedBox(height: 32.0),
                  if (model.isLoading)
                    Center(child: CircularProgressIndicator())
                  else
                    _buildSubmitButton(model),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(MainModel model) {
    //
    void onSubmitPressed(context) async {
      final result = await _submitForm(model);
      switch (result) {
        case _SubmitResult.success:
          Navigator.pushReplacementNamed(context, '/');
          break;
        case _SubmitResult.networkError:
          showDialog(context: context, builder: _buildErrorDialog);
          break;
        default:
      }
    }

    return RaisedButton(
      child: const Text('Save'),
      textColor: Colors.white,
      onPressed: () => onSubmitPressed(context),
    );
  }

  AlertDialog _buildErrorDialog(context) {
    return AlertDialog(
      title: const Text('Something went wrong'),
      content: const Text('Please try again'),
      actions: <Widget>[
        FlatButton(
          child: const Text('Ok'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }

  TextFormField _buildPriceTextField(Product product) {
    return TextFormField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(labelText: 'Price'),
      initialValue: product != null ? product.price.toString() : '',
      validator: (String value) {
        if (value.isEmpty || double.tryParse(value) == null) {
          return 'Price has to be a double.';
        }
      },
      onSaved: (String value) => _formData['price'] = double.parse(value),
    );
  }

  TextFormField _buildDescriptionTextField(Product product) {
    return TextFormField(
      maxLines: 4,
      decoration: const InputDecoration(labelText: 'Description'),
      initialValue: product != null ? product.description : '',
      validator: (String value) {
        if (value.isEmpty || value.length < 10) {
          return 'Description has to be at least 10 characters.';
        }
      },
      onSaved: (String value) => _formData['description'] = value,
    );
  }

  TextFormField _buildTitleTextField(Product product) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Title'),
      initialValue: product != null ? product.title : '',
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return 'Title has to be at least 5 characters.';
        }
      },
      onSaved: (String value) => _formData['title'] = value,
    );
  }

  Future<_SubmitResult> _submitForm(MainModel model) async {
    //
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (model.selectedProduct == null) {
        final success = await model.addProduct(
          title: _formData['title'],
          description: _formData['description'],
          price: _formData['price'],
          imageUrl: _formData['imageUrl'],
        );
        return success ? _SubmitResult.success : _SubmitResult.networkError;
      } else {
        final success = await model.updateProduct(
          title: _formData['title'],
          description: _formData['description'],
          price: _formData['price'],
          imageUrl: _formData['imageUrl'],
        );
        return success ? _SubmitResult.success : _SubmitResult.networkError;
      }
    }
    return _SubmitResult.validationFailed;
  }
}

enum _SubmitResult { success, validationFailed, networkError }
