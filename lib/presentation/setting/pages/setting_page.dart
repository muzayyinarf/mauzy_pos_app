import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mauzy_pos_app/core/components/menu_button.dart';
import 'package:mauzy_pos_app/core/components/spaces.dart';
import 'package:mauzy_pos_app/core/constants/colors.dart';
import 'package:mauzy_pos_app/core/extensions/build_context_ext.dart';
import 'package:mauzy_pos_app/data/datasources/auth_local_datasource.dart';
import 'package:mauzy_pos_app/data/datasources/product_local_datasource.dart';
import 'package:mauzy_pos_app/presentation/auth/pages/login_page.dart';
import 'package:mauzy_pos_app/presentation/home/bloc/product/product_bloc.dart';
import 'package:mauzy_pos_app/presentation/setting/pages/manage_product_page.dart';

import '../../../core/assets/assets.gen.dart';
import '../../home/bloc/logout/logout_bloc.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Setting'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                MenuButton(
                  iconPath: Assets.images.manageProduct.path,
                  label: 'Kelola Produk',
                  onPressed: () => context.push(const ManageProductPage()),
                  isImage: true,
                ),
                const SpaceWidth(15.0),
                MenuButton(
                  iconPath: Assets.images.managePrinter.path,
                  label: 'Kelola Printer',
                  onPressed: () => context.push(const ManageProductPage()),
                  isImage: true,
                ),
              ],
            ),
            const SpaceHeight(60),
            BlocConsumer<ProductBloc, ProductState>(
              listener: (context, state) {
                state.maybeMap(
                  orElse: () {},
                  success: (value) async {
                    await ProductLocalDatasource.instance.removeAllProduct();
                    await ProductLocalDatasource.instance
                        .insertAllProduct(value.products);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Sync data success'),
                      backgroundColor: AppColors.primary,
                    ));
                  },
                );
              },
              builder: (context, state) {
                return state.maybeMap(
                  orElse: () {
                    return ElevatedButton(
                      onPressed: () {
                        context
                            .read<ProductBloc>()
                            .add(const ProductEvent.fetch());
                      },
                      child: const Text('Sync Data'),
                    );
                  },
                  loading: (value) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            const Divider(),
            BlocConsumer<LogoutBloc, LogoutState>(
              listener: (context, state) {
                state.maybeMap(
                  orElse: () {},
                  success: (value) async {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ));
                    return AuthLocalDatasource().removeAuthData();
                  },
                );
              },
              builder: (context, state) {
                return state.maybeMap(
                  orElse: () {
                    return ElevatedButton(
                      onPressed: () {
                        context
                            .read<LogoutBloc>()
                            .add(const LogoutEvent.logout());
                      },
                      child: const Text('Logout'),
                    );
                  },
                  loading: (value) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            const Divider(),
          ],
        ));
  }
}
