import 'SettingValue.dart';

class MaxgaApplicationSetting {
  bool readOnWiFi;
  MaxgaApplicationSetting.fromJson(setting) {
    readOnWiFi = setting['readOnWifi'];
  }

}


class MaxgaSettingItem {
  MaxgaSettingItemType name;
  String title;
  String subTitle;
  String description;
  MaxgaSettingCategoryType category;
  String value;

  setValue(String value) {
    switch(category) {
      case MaxgaSettingCategoryType.application: {
        this.value = value;
        break;
      }
      default: {
        this.value = value;
      }
    }
  }


  MaxgaSettingItem({this.name, this.subTitle, this.description, this.category,
      this.value,this.title});

  MaxgaSettingItem.formJson(Map<String, dynamic> settingItem) {
    name = settingItem['name'];
    title = settingItem['title'];

    subTitle = settingItem['subTitle'];

    description = settingItem['description'];

    category = settingItem['category'];

    value = settingItem['value'];

  }

  MaxgaSettingItem.copy(MaxgaSettingItem settingItem) {
    name = settingItem.name;
    title = settingItem.title;

    subTitle = settingItem.subTitle;

    description = settingItem.description;

    category = settingItem.category;

    value = settingItem.value;
  }
}
