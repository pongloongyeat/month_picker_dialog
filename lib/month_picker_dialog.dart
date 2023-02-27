import 'package:flutter/material.dart';
import '/src/helpers/controller.dart';
import '/src/helpers/locale_utils.dart';
import '/src/month_picker_widgets/button_bar.dart';
import '/src/month_picker_widgets/header.dart';
import '/src/month_picker_widgets/pager.dart';
import 'src/month_selector/month_selector.dart';
import 'src/year_selector/year_selector.dart';

/// Displays month picker dialog.
///
/// [initialDate] is the initially selected month.
///
/// [firstDate] is the optional lower bound for month selection.
///
/// [lastDate] is the optional upper bound for month selection.
///
/// [selectableMonthPredicate] lets you control enabled months just like the official selectableDayPredicate.
///
/// [capitalizeFirstLetter] lets you control if your months names are capitalized or not.
///
/// [headerColor] lets you control the calendar header color.
///
/// [headerTextColor] lets you control the calendar header text and arrows color.
///
/// [selectedMonthBackgroundColor] lets you control the current selected month/year background color.
///
/// [selectedMonthTextColor] lets you control the text color of the current selected month/year.
///
/// [unselectedMonthTextColor] lets you control the text color of the current unselected months/years.
///
/// [confirmText] lets you set a custom confirm text widget.
///
/// [cancelText] lets you set a custom cancel text widget.
///
/// [customHeight] lets you set a custom height for the calendar widget.
///
/// [customWidth] lets you set a custom width for the calendar widget.
///
/// [yearFirst] lets you define that the user must select first the year, then the month.
///
/// [dismissible] lets you define if the dialog will be dismissible by clicking outside it.
///
/// [roundedCornersRadius] lets you define the Radius of the rounded dialog (default is 0).
///
Future<DateTime?> showMonthPicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  Locale? locale,
  bool Function(DateTime)? selectableMonthPredicate,
  bool capitalizeFirstLetter = true,
  Color? headerColor,
  Color? headerTextColor,
  Color? selectedMonthBackgroundColor,
  Color? selectedMonthTextColor,
  Color? unselectedMonthTextColor,
  Text? confirmText,
  Text? cancelText,
  double? customHeight,
  double? customWidth,
  bool yearFirst = false,
  bool dismissible = false,
  double roundedCornersRadius = 0,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierDismissible: dismissible,
    builder: (BuildContext context) {
      final MonthpickerController controller = MonthpickerController(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        locale: locale,
        selectableMonthPredicate: selectableMonthPredicate,
        capitalizeFirstLetter: capitalizeFirstLetter,
        headerColor: headerColor,
        headerTextColor: headerTextColor,
        selectedMonthBackgroundColor: selectedMonthBackgroundColor,
        selectedMonthTextColor: selectedMonthTextColor,
        unselectedMonthTextColor: unselectedMonthTextColor,
        confirmText: confirmText,
        cancelText: cancelText,
        customHeight: customHeight,
        customWidth: customWidth,
        yearFirst: yearFirst,
        roundedCornersRadius: roundedCornersRadius,
      );
      return _MonthPickerDialog(controller: controller);
    },
  );
}

class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog({required this.controller});
  final MonthpickerController controller;
  @override
  _MonthPickerDialogState createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late Widget _selector;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
    _selector = widget.controller.yearFirst
        ? YearSelector(
            key: widget.controller.yearSelectorState,
            onYearSelected: _onYearSelected,
            controller: widget.controller,
          )
        : MonthSelector(
            key: widget.controller.monthSelectorState,
            openDate: widget.controller.selectedDate,
            selectedDate: widget.controller.selectedDate,
            selectableMonthPredicate:
                widget.controller.selectableMonthPredicate,
            upDownPageLimitPublishSubject:
                widget.controller.upDownPageLimitPublishSubject,
            upDownButtonEnableStatePublishSubject:
                widget.controller.upDownButtonEnableStatePublishSubject,
            firstDate: widget.controller.localFirstDate,
            lastDate: widget.controller.localLastDate,
            onMonthSelected: _onMonthSelected,
            locale: widget.controller.locale,
            capitalizeFirstLetter: widget.controller.capitalizeFirstLetter,
            selectedMonthBackgroundColor:
                widget.controller.selectedMonthBackgroundColor,
            selectedMonthTextColor: widget.controller.selectedMonthTextColor,
            unselectedMonthTextColor:
                widget.controller.unselectedMonthTextColor,
          );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String locale =
        getLocale(context, selectedLocale: widget.controller.locale);
    final bool portrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final Container content = Container(
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: portrait
            ? BorderRadius.only(
                bottomLeft:
                    Radius.circular(widget.controller.roundedCornersRadius),
                bottomRight:
                    Radius.circular(widget.controller.roundedCornersRadius),
              )
            : BorderRadius.only(
                topRight:
                    Radius.circular(widget.controller.roundedCornersRadius),
                bottomRight:
                    Radius.circular(widget.controller.roundedCornersRadius),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          PickerPager(
            selector: _selector,
            theme: theme,
            customHeight: widget.controller.customHeight,
            customWidth: widget.controller.customWidth,
          ),
          PickerButtonBar(
            cancelText: widget.controller.cancelText,
            confirmText: widget.controller.confirmText,
            defaultcancelButtonLabel: 'CANCEL',
            defaultokButtonLabel: 'OK',
            cancelFunction: () => Navigator.pop(context, null),
            okFunction: () =>
                Navigator.pop(context, widget.controller.selectedDate),
          ),
        ],
      ),
    );

    final PickerHeader header = PickerHeader(
      theme: theme,
      locale: locale,
      headerColor: widget.controller.headerColor,
      headerTextColor: widget.controller.headerTextColor,
      capitalizeFirstLetter: widget.controller.capitalizeFirstLetter,
      selectedDate: widget.controller.selectedDate,
      isMonthSelector: _selector is MonthSelector,
      onDownButtonPressed: _onDownButtonPressed,
      onSelectYear: _onSelectYear,
      onUpButtonPressed: _onUpButtonPressed,
      upDownButtonEnableStatePublishSubject:
          widget.controller.upDownButtonEnableStatePublishSubject,
      upDownPageLimitPublishSubject:
          widget.controller.upDownPageLimitPublishSubject,
      roundedCornersRadius: widget.controller.roundedCornersRadius,
      portrait: portrait,
    );

    return Theme(
      data: theme.copyWith(dialogBackgroundColor: Colors.transparent),
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Builder(
              builder: (BuildContext context) {
                if (portrait) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [header, content],
                  );
                }
                return IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [header, content],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onSelectYear() => setState(
        () => _selector = YearSelector(
          key: widget.controller.yearSelectorState,
          onYearSelected: _onYearSelected,
          controller: widget.controller,
        ),
      );

  void _onYearSelected(final int year) {
    setState(
      () {
        //widget.controller.selectedDate = DateTime(year);
        _selector = MonthSelector(
          key: widget.controller.monthSelectorState,
          openDate: DateTime(year),
          selectedDate: widget.controller.selectedDate,
          selectableMonthPredicate: widget.controller.selectableMonthPredicate,
          upDownPageLimitPublishSubject:
              widget.controller.upDownPageLimitPublishSubject,
          upDownButtonEnableStatePublishSubject:
              widget.controller.upDownButtonEnableStatePublishSubject,
          firstDate: widget.controller.localFirstDate,
          lastDate: widget.controller.localLastDate,
          onMonthSelected: _onMonthSelected,
          locale: widget.controller.locale,
          capitalizeFirstLetter: widget.controller.capitalizeFirstLetter,
          selectedMonthBackgroundColor:
              widget.controller.selectedMonthBackgroundColor,
          selectedMonthTextColor: widget.controller.selectedMonthTextColor,
          unselectedMonthTextColor: widget.controller.unselectedMonthTextColor,
        );
      },
    );
  }

  void _onMonthSelected(final DateTime date) => setState(
        () {
          widget.controller.selectedDate = date;
          _selector = MonthSelector(
            key: widget.controller.monthSelectorState,
            openDate: widget.controller.selectedDate,
            selectedDate: widget.controller.selectedDate,
            selectableMonthPredicate:
                widget.controller.selectableMonthPredicate,
            upDownPageLimitPublishSubject:
                widget.controller.upDownPageLimitPublishSubject,
            upDownButtonEnableStatePublishSubject:
                widget.controller.upDownButtonEnableStatePublishSubject,
            firstDate: widget.controller.localFirstDate,
            lastDate: widget.controller.localLastDate,
            onMonthSelected: _onMonthSelected,
            locale: widget.controller.locale,
            capitalizeFirstLetter: widget.controller.capitalizeFirstLetter,
            selectedMonthBackgroundColor:
                widget.controller.selectedMonthBackgroundColor,
            selectedMonthTextColor: widget.controller.selectedMonthTextColor,
            unselectedMonthTextColor:
                widget.controller.unselectedMonthTextColor,
          );
        },
      );

  void _onUpButtonPressed() {
    if (widget.controller.yearSelectorState.currentState != null) {
      widget.controller.yearSelectorState.currentState!.goUp();
    } else {
      widget.controller.monthSelectorState.currentState!.goUp();
    }
  }

  void _onDownButtonPressed() {
    if (widget.controller.yearSelectorState.currentState != null) {
      widget.controller.yearSelectorState.currentState!.goDown();
    } else {
      widget.controller.monthSelectorState.currentState!.goDown();
    }
  }
}
