import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nextcloud/nextcloud.dart' as nextcloud;
import 'package:nextcloud_talk/nextcloud_talk.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'nextcloud_talk_localizations.dart';
import 'nextcloud_talk_utils.dart';

// ignore: public_member_api_docs
class NextcloudTalkCreateChatDialog extends StatefulWidget {
  @override
  _NextcloudTalkCreateChatDialogState createState() =>
      _NextcloudTalkCreateChatDialogState();
}

class _NextcloudTalkCreateChatDialogState
    extends State<NextcloudTalkCreateChatDialog> {
  bool _groupChat = false;
  final TextEditingController _searchFieldController = TextEditingController();
  List<nextcloud.User> _selectedUsers = [];
  List<nextcloud.User> _suggestedUsers = [];
  String _currentQuery = '';
  String _name;
  bool _searchLoading = false;

  @override
  Widget build(BuildContext context) => SimpleDialog(
        contentPadding: EdgeInsets.only(left: 5, right: 5, top: 10),
        title: Text(
          NextcloudTalkLocalizations.createNewChat,
          style: TextStyle(
            color: ThemeWidget.of(context).textColor,
          ),
        ),
        children: [
          DialogContentWrapper(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(NextcloudTalkLocalizations.groupChat),
                  ),
                  Switch(
                    value: _groupChat,
                    activeColor: Theme.of(context).accentColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedUsers = [
                          if (_selectedUsers.isNotEmpty) _selectedUsers[0],
                        ];
                        _groupChat = value;
                      });
                    },
                  ),
                ],
              ),
              if (_groupChat)
                TextField(
                  decoration: InputDecoration(
                    hintText: NextcloudTalkLocalizations.chatName,
                  ),
                  onChanged: (name) {
                    setState(() {
                      _name = name;
                    });
                  },
                ),
              if (_selectedUsers.isEmpty)
                Container(
                  margin: EdgeInsets.only(top: 7.5, bottom: 7.5),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(_groupChat
                            ? NextcloudTalkLocalizations.noUsersSelected
                            : NextcloudTalkLocalizations.noUserSelected),
                      ),
                    ],
                  ),
                )
              else
                Builder(
                  builder: (context) {
                    final widgets = _usersToWidgets(_selectedUsers);
                    return Column(
                      children: List.generate(
                        widgets.length,
                        (index) => InkWell(
                          onTap: () {
                            setState(() {
                              _selectedUsers.removeAt(index);
                            });
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: widgets[index],
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              TextField(
                decoration: InputDecoration(
                  hintText: NextcloudTalkLocalizations.searchUser,
                ),
                controller: _searchFieldController,
                onChanged: (query) {
                  if (query == '') {
                    setState(() {
                      _currentQuery = '';
                      _searchLoading = false;
                      _suggestedUsers = [];
                    });
                  } else {
                    setState(() {
                      _searchLoading = true;
                      _currentQuery = query;
                    });
                    NextcloudTalkWidget.of(context)
                        .feature
                        .loader
                        .client
                        .autocomplete
                        .searchUser(query)
                        .then((users) {
                      if (query == _currentQuery) {
                        if (mounted) {
                          setState(() {
                            _searchLoading = false;
                            _suggestedUsers = users
                                .where(
                                    (user) => user.id != Static.user.username)
                                .toList();
                          });
                        }
                      }
                    });
                  }
                },
              ),
              if (_currentQuery == '')
                Container()
              else if (_searchLoading)
                Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  child: Center(
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CustomCircularProgressIndicator(),
                    ),
                  ),
                )
              else if (_suggestedUsers.isEmpty)
                Container(
                  margin: EdgeInsets.only(top: 7.5, bottom: 7.5),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.orangeAccent,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(NextcloudTalkLocalizations.noUsersFound),
                      ),
                    ],
                  ),
                )
              else ...[
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text('${NextcloudTalkLocalizations.searchResults}:'),
                ),
                Builder(
                  builder: (context) {
                    final filteredUserSuggestions = _suggestedUsers
                        .where((u) => !_selectedUsers.contains(u))
                        .toList();
                    final widgets = _usersToWidgets(filteredUserSuggestions);
                    return Column(
                      children: List.generate(
                        widgets.length,
                        (index) => InkWell(
                          onTap: () {
                            setState(() {
                              if (!_groupChat) {
                                _selectedUsers = [];
                              }
                              _selectedUsers
                                  .add(filteredUserSuggestions[index]);
                            });
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: widgets[index],
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.check,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
              CustomButton(
                onPressed: _selectedUsers.isNotEmpty &&
                        (!_groupChat || (_name != null && _name.isNotEmpty))
                    ? () {
                        Navigator.of(context).pop([
                          _groupChat,
                          _name,
                          _selectedUsers.map((u) => u.id).toList(),
                        ]);
                      }
                    : null,
                child: Text(
                  AppLocalizations.ok,
                  style: TextStyle(color: darkColor),
                ),
              ),
            ],
          ),
        ],
      );

  List<Widget> _usersToWidgets(List<nextcloud.User> users) => users
      .cast<nextcloud.User>()
      .map((user) => Container(
            margin: EdgeInsets.only(top: 2.5, bottom: 2.5),
            child: InkWell(
              child: Container(
                margin: EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  children: [
                    SizedBox(
                      height: 30,
                      child: CustomCachedNetworkImage(
                        provider: CustomCachedNetworkImageAvatarProvider(
                          avatarClient: NextcloudTalkWidget.of(context)
                              .feature
                              .loader
                              .client
                              .avatar,
                          username: user.id,
                          size: 30,
                        ),
                        height: 30,
                        width: 30,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(user.label),
                    ),
                  ],
                ),
              ),
            ),
          ))
      .toList()
      .cast<Widget>()
      .toList();
}
