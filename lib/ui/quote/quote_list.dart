import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invoiceninja_flutter/data/models/invoice_model.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/ui/app/loading_indicator.dart';
import 'package:invoiceninja_flutter/ui/app/snackbar_row.dart';
import 'package:invoiceninja_flutter/ui/invoice/invoice_list_item.dart';
import 'package:invoiceninja_flutter/ui/quote/quote_list_vm.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class QuoteList extends StatelessWidget {
  final QuoteListVM viewModel;

  const QuoteList({
    Key key,
    @required this.viewModel,
  }) : super(key: key);

  void _showMenu(
      BuildContext context, InvoiceEntity quote, ClientEntity client) async {
    final user = viewModel.user;
    final message = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => SimpleDialog(children: <Widget>[
          user.canCreate(EntityType.quote)
              ? ListTile(
            leading: Icon(Icons.control_point_duplicate),
            title: Text(AppLocalization.of(context).clone),
            onTap: () => viewModel.onEntityAction(
                context, quote, EntityAction.clone),
          )
              : Container(),
          user.canEditEntity(quote) && !quote.isPublic
              ? ListTile(
            leading: Icon(Icons.publish),
            title: Text(AppLocalization.of(context).markSent),
            onTap: () => viewModel.onEntityAction(
                context, quote, EntityAction.markSent),
          )
              : Container(),
          user.canEditEntity(quote) && client.hasEmailAddress
              ? ListTile(
            leading: Icon(Icons.send),
            title: Text(AppLocalization.of(context).email),
            onTap: () => viewModel.onEntityAction(
                context, quote, EntityAction.email),
          )
              : Container(),
          ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text(AppLocalization.of(context).pdf),
            onTap: () => viewModel.onEntityAction(
                context, quote, EntityAction.pdf),
          ),
          Divider(),
          user.canEditEntity(quote) && !quote.isActive
              ? ListTile(
            leading: Icon(Icons.restore),
            title: Text(AppLocalization.of(context).restore),
            onTap: () => viewModel.onEntityAction(
                context, quote, EntityAction.restore),
          )
              : Container(),
          user.canEditEntity(quote) && quote.isActive
              ? ListTile(
            leading: Icon(Icons.archive),
            title: Text(AppLocalization.of(context).archive),
            onTap: () => viewModel.onEntityAction(
                context, quote, EntityAction.archive),
          )
              : Container(),
          user.canEditEntity(quote) && !quote.isDeleted
              ? ListTile(
            leading: Icon(Icons.delete),
            title: Text(AppLocalization.of(context).delete),
            onTap: () => viewModel.onEntityAction(
                context, quote, EntityAction.delete),
          )
              : Container(),
        ]));
    if (message != null) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: SnackBarRow(
            message: message,
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final listState = viewModel.listState;
    final filteredClientId = listState.filterClientId;
    final filteredClient =
    filteredClientId != null ? viewModel.clientMap[filteredClientId] : null;

    return Column(
      children: <Widget>[
        filteredClient != null
            ? Material(
          color: Colors.orangeAccent,
          elevation: 6.0,
          child: InkWell(
            onTap: () => viewModel.onViewClientFilterPressed(context),
            child: Row(
              children: <Widget>[
                SizedBox(width: 18.0),
                Expanded(
                  child: Text(
                    localization.clientsInvoices.replaceFirst(
                        ':client', filteredClient.displayName),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => viewModel.onClearClientFilterPressed(),
                )
              ],
            ),
          ),
        )
            : Container(),
        Expanded(
          child: !viewModel.isLoaded
              ? LoadingIndicator()
              : RefreshIndicator(
            onRefresh: () => viewModel.onRefreshed(context),
            child: viewModel.quoteList.isEmpty
                ? Opacity(
              opacity: 0.5,
              child: Center(
                child: Text(
                  AppLocalization.of(context).noRecordsFound,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: viewModel.quoteList.length,
              itemBuilder: (BuildContext context, index) {
                final quoteId = viewModel.quoteList[index];
                final quote = viewModel.quoteMap[quoteId];
                final client =
                viewModel.clientMap[quote.clientId];
                return Column(
                  children: <Widget>[
                    InvoiceListItem(
                      user: viewModel.user,
                      filter: viewModel.filter,
                      invoice: quote,
                      client: viewModel.clientMap[quote.clientId],
                      onDismissed: (DismissDirection direction) =>
                          viewModel.onDismissed(
                              context, quote, direction),
                      onTap: () =>
                          viewModel.onQuoteTap(context, quote),
                      onLongPress: () =>
                          _showMenu(context, quote, client),
                    ),
                    Divider(
                      height: 1.0,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
