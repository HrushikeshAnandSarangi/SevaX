import 'package:flutter/material.dart';
import 'package:sevaexchange/views/login/login_page.dart';
import 'package:sevaexchange/views/login/register_page.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class ExplorePageAppBar extends PreferredSize {
  final ValueChanged<String> onSearchChanged;
  final bool hideSearchBar;
  final TextEditingController controller;

  ExplorePageAppBar(
      {this.controller, this.hideSearchBar = false, this.onSearchChanged});

  @override
  Size get preferredSize => Size.fromHeight(210);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('images/waves.png'),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 30),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).maybePop();
                  },
                  child: Image.asset(
                    'images/seva_x_logo.png',
                    width: 110,
                    height: 31,
                  ),
                ),
                Spacer(),
                appBarButton(
                  'Sign Up',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                      ),
                    );
                  },
                ),
                appBarButton(
                  'Sign In',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            HideWidget(
              hide: hideSearchBar,
              child: Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: controller,
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Try "Oska" "Postal Code"',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: FlatButton(
                          child: Text('Search'),
                          textColor: Colors.white,
                          color: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () {},
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlatButton appBarButton(String text, VoidCallback onTap) {
    return FlatButton(
      padding: EdgeInsets.zero,
      child: Text(text),
      textColor: Colors.white,
      onPressed: onTap,
    );
  }
}
