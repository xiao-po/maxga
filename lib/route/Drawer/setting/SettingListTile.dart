import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/base/setting/Setting.model.dart';
import 'package:maxga/base/setting/SettingValue.dart';
import 'package:maxga/provider/SettingProvider.dart';

class SettingListTile extends StatelessWidget {
  final MaxgaSettingItem setting;

  const SettingListTile({Key key, this.setting}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    switch(setting.category) {
      case MaxgaSettingCategoryType.application: {
        return _ReadOnWiFiSettingItem(setting: setting);
      }
      default: {
        return ListTile(
          title: const Text('没有类型的选项'),
          subtitle: Text(setting?.value ?? '') ?? null
        );
      }
    }

  }
}

class _ReadOnWiFiSettingItem extends StatelessWidget {
  final MaxgaSettingItem setting;

  const _ReadOnWiFiSettingItem({Key key, this.setting}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: setting.value == '1',
      title: Text(setting.title),
      onChanged: (checked) {
        SettingProvider.getInstance().modifySetting(setting, checked ? '1':'0');
      },
    );
  }

}