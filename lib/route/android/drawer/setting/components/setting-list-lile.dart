import 'package:flutter/material.dart';
import 'package:maxga/base/setting/setting.model.dart';
import 'package:maxga/constant/SettingValue.dart';
import 'package:maxga/components/form/setting-form/select-config-page.dart';
import 'package:maxga/components/form/setting-form/list-tile.dart';
import 'package:maxga/provider/public/SettingProvider.dart';
import 'package:provider/provider.dart';

const SettingListTilePadding = const EdgeInsets.only(left: 24, right: 20);

class SettingListTile extends StatelessWidget {
  final MaxgaSettingItem setting;

  const SettingListTile(this.setting, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (setting.type) {
      case MaxgaSettingListTileType.checkbox:
        return CheckBoxSettingListTile(setting: setting);
      case MaxgaSettingListTileType.select:
        return DropDownSettingListTile(setting: setting);
      case MaxgaSettingListTileType.title:
        return TitleSettingListTile(text: setting.subTitle);
      case MaxgaSettingListTileType.command:
        return CommandSettingListTile(setting: setting);
      case MaxgaSettingListTileType.confirmCommand:
        return AlertCommandSettingListTile(setting: setting);
      case MaxgaSettingListTileType.page:
        if (setting is MaxgaSettingPageItem) {
          return SettingPageListTile(
              setting: (setting as MaxgaSettingPageItem));
        }
        return ListTile(
            title: const Text('没有类型的选项'),
            subtitle: Text(setting?.value ?? '') ?? null);
      case MaxgaSettingListTileType.text:
      default:
        {
          return ListTile(
              title: const Text('没有类型的选项'),
              subtitle: Text(setting?.value ?? '') ?? null);
        }
    }
  }
}

class TitleSettingListTile extends StatelessWidget {
  final String text;

  const TitleSettingListTile({Key key, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: EdgeInsets.only(top: 10, left: 15),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).accentColor),
      ),
    );
  }
}

class CommandSettingListTile extends StatelessWidget {
  final MaxgaSettingItem setting;

  const CommandSettingListTile({Key key, @required this.setting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaxgaConfigListTile(
      title: Text(setting.title),
//      subtitle: setting.subTitle != null ? Text(setting.subTitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onPressed: () async {
        var isSuccess =
            await Provider.of<SettingProvider>(context).onChange(setting);
        if (isSuccess) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('${setting.title}结束'),
          ));
        }
      },
    );
  }
}

class AlertCommandSettingListTile extends StatelessWidget {
  final MaxgaSettingItem setting;

  const AlertCommandSettingListTile({Key key, @required this.setting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaxgaConfigListTile(
        title: Text(setting.title),
//        subtitle: setting.subTitle != null ? Text(setting.subTitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onPressed: () async {
          showDialog(
              context: context,
              child: AlertDialog(
                title: Text('是否要 ${setting.title} ?'),
                actions: <Widget>[
                  FlatButton(
                      child: const Text('取消'),
                      onPressed: () => Navigator.pop(context)),
                  FlatButton(
                      child: const Text('确定'),
                      onPressed: () async {
                        var isSuccess =
                            await Provider.of<SettingProvider>(context)
                                .onChange(setting);
                        Navigator.pop(context);
                        if (isSuccess) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('${setting.title}结束'),
                          ));
                        }
                      }),
                ],
              ));
        });
  }
}

class CheckBoxSettingListTile extends StatelessWidget {
  final MaxgaSettingItem setting;

  const CheckBoxSettingListTile({Key key, @required this.setting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaxgaConfigListTile(
      title: Text(setting.title),
      subTitle: setting.subTitle != null ? Text(setting.subTitle) : null,
      onPressed: () {
        var checked = !(setting.value == '1');
        changeValue(context, checked);
      },
      trailing: SizedBox(
        height: 20,
        child: Switch(
            onChanged: (bool value) => changeValue(context, value),
            value: setting.value == '1'),
      ),
    );
  }

  void changeValue(BuildContext context, bool checked) {
    Provider.of<SettingProvider>(context)
        .modifySetting(setting, checked ? '1' : '0');
  }
}

class DropDownSettingListTile extends StatelessWidget {
  final MaxgaSettingItem setting;

  const DropDownSettingListTile({Key key, @required this.setting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var selectOptions = MaxgaSelectOptionsMap[setting.key];
    var value = selectOptions.firstWhere((option) => option.value == setting.value).title;
    return MaxgaConfigListTile(
        title: Text(setting.title),
//      contentPadding: SettingListTilePadding,
        subTitle: setting.subTitle != null ? Text(setting.subTitle) : null,
        trailing: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: value, style: TextStyle(color: Colors.grey[400])),
            const WidgetSpan(child: const Icon(Icons.chevron_right))
          ]),
        ),
        onPressed: () => toSelectConfigPage(context));
  }

  toSelectConfigPage(BuildContext context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Consumer<SettingProvider>(
                  builder: (context, value, child) => SelectConfigPage(
                    title: Text(setting.title),
                    active: value.getItemValue(setting.key),
                    items: MaxgaSelectOptionsMap[setting.key],
                    onSelect: (item) {
                      value.modifySetting(setting, item.value);
                    },
                  ),
                )));
  }
}


class SettingPageListTile extends StatelessWidget {
  final MaxgaSettingPageItem setting;

  const SettingPageListTile({Key key, @required this.setting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(setting.title),
      contentPadding: SettingListTilePadding,
      subtitle: setting.subTitle != null ? Text(setting.subTitle) : null,
      trailing: Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => setting.pageBuilder(context))),
    );
  }
}
