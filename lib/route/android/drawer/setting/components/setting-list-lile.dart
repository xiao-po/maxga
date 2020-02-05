import 'package:flutter/material.dart';
import 'package:maxga/base/setting/Setting.model.dart';
import 'package:maxga/base/setting/SettingValue.dart';
import 'package:maxga/provider/public/SettingProvider.dart';
import 'package:provider/provider.dart';

const SettingListTilePadding = const EdgeInsets.only(left: 24, right: 20);

class SettingListTile extends StatelessWidget {
  final MaxgaSettingItem setting;

  const SettingListTile({Key key, this.setting}) : super(key: key);

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
        if(setting is MaxgaSettingPageItem) {
          return SettingPageListTile(setting: (setting as MaxgaSettingPageItem));
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
    return ListTile(
      contentPadding: SettingListTilePadding,
      title: Text(setting.title),
      subtitle: setting.subTitle != null ? Text(setting.subTitle) : null,
      onTap: () async {
        var isSuccess = await Provider.of<SettingProvider>(context)
            .onChange(setting);
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
    return ListTile(
        contentPadding: SettingListTilePadding,
        title: Text(setting.title),
        subtitle: setting.subTitle != null ? Text(setting.subTitle) : null,
        onTap: () async {
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
    return CheckboxListTile(
      value: setting.value == '1',
      title: Text('  ' + setting.title),
      subtitle: setting.subTitle != null ? Text('  ' + setting.subTitle) : null,
      onChanged: (checked) {
        Provider.of<SettingProvider>(context)
            .modifySetting(setting, checked ? '1' : '0');
      },
    );
  }
}

class DropDownSettingListTile extends StatelessWidget {
  final MaxgaSettingItem setting;

  const DropDownSettingListTile({Key key, @required this.setting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(setting.title),
      contentPadding: SettingListTilePadding,
      subtitle: setting.subTitle != null ? Text(setting.subTitle) : null,
      trailing: DropdownButton<String>(
        value: setting.value,
        onChanged: (String newValue) {
          Provider.of<SettingProvider>(context)
              .modifySetting(setting, newValue);
        },
        items: MaxgaDropDownOptionsMap[setting.key],
      ),
    );
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
        context, MaterialPageRoute(builder: (context) => setting.pageBuilder(context))
      ),
    );
  }
}
