import 'package:admin_panel_coupons/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../screens/edit_coupon_screen.dart';
import '../providers/coupons_provider.dart';

class AdminCouponItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  AdminCouponItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 150,
        child: Row(children: [
          IconButton(
            onPressed: () {
              // Navigator.of(context)
              // .pushNamed(EditCouponScreen.routeName, arguments: id);
            },
            icon: Icon(Icons.edit),
          ),
          SizedBox(width: defaultPadding * 2),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: Text('Remove Coupon'),
                        content: Text(
                            'Are you sure you want to delete this coupon?'),
                        actions: [
                          MaterialButton(
                              child: Text(
                                'No',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              }),
                          MaterialButton(
                              child: Text('Yes'),
                              onPressed: () async {
                                try {
                                  await Provider.of<CouponsProvider>(context,
                                          listen: false)
                                      .deleteCoupon(id);
                                } catch (error) {
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                      content: Text(
                                    'Failed to delete coupon!',
                                    textAlign: TextAlign.center,
                                  )));
                                }
                                Navigator.of(ctx).pop();
                              }),
                        ],
                      ));
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
          ),
        ]),
      ),
    );
  }
}