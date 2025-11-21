enum ListPermission {
  owner,    // Владелец - полный доступ
  editor,   // Редактор - может редактировать
  viewer,   // Только просмотр
}

extension ListPermissionExtension on ListPermission {
  bool get canEdit => this == ListPermission.owner || this == ListPermission.editor;
  bool get canDelete => this == ListPermission.owner;
  bool get canInvite => this == ListPermission.owner || this == ListPermission.editor;
  
  String get displayName {
    switch (this) {
      case ListPermission.owner:
        return 'Владелец';
      case ListPermission.editor:
        return 'Редактор';
      case ListPermission.viewer:
        return 'Только просмотр';
    }
  }
}

