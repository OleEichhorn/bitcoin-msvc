(set _ROOT=%CD%\..)
(set EX_ROOT=%_ROOT%\external)
(set QT_ROOT=%EX_ROOT%\qt)
(set QT_PLUGIN_PATH=%QT_ROOT%\qtbase\plugins)
(set SRC_PATH=bitcoin)
(set OUT_PATH=%CD%\build)
(set PATH=%EX_ROOT%\bin\x64\release;%QT_ROOT%\qtbase\bin;%QT_ROOT%\qtbase\lib;%PATH:)=^)%) 

if not exist "%OUT_PATH%" mkdir "%OUT_PATH%"

forfiles /p %SRC_PATH%\src\qt\locale\ /m *.ts /c "cmd /c lrelease  @file -qm @fname.qm"

forfiles /p %SRC_PATH%\src\qt\forms\ /m *.ui /c "cmd /c uic  @file -o %OUT_PATH%\ui_@fname.h"

set MOC_DEF=-DENABLE_WALLET -DUNICODE -DWIN32 -DQT_GUI -DBOOST_THREAD_USE_LIB -DBOOST_SPIRIT_THREADSAFE -DQT_WIDGETS_LIB -DQT_NETWORK_LIB -DQT_GUI_LIB -DQT_CORE_LIB -D_MSC_VER=1700 -D_WIN32 -I%QT_ROOT%/qtbase/mkspecs/win32-msvc2013 -I%SRC_PATH%\src -I%SRC_PATH%/src/json -I%SRC_PATH%/src/qt -I%QT_ROOT%/qtbase/include -I%QT_ROOT%/qtbase/include/QtWidgets -I%QT_ROOT%/qtbase/include/QtNetwork -I%QT_ROOT%/qtbase/include/QtGui -I%QT_ROOT%/qtbase/include/QtCore
moc %MOC_DEF%  %SRC_PATH%\src\qt\addressbookpage.h -o %OUT_PATH%\moc_addressbookpage.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\addresstablemodel.h -o %OUT_PATH%\moc_addresstablemodel.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\askpassphrasedialog.h -o %OUT_PATH%\moc_askpassphrasedialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\bitcoinaddressvalidator.h -o %OUT_PATH%\moc_bitcoinaddressvalidator.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\bitcoinamountfield.h -o %OUT_PATH%\moc_bitcoinamountfield.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\bitcoingui.h -o %OUT_PATH%\moc_bitcoingui.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\bitcoinunits.h -o %OUT_PATH%\moc_bitcoinunits.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\clientmodel.h -o %OUT_PATH%\moc_clientmodel.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\coincontroldialog.h -o %OUT_PATH%\moc_coincontroldialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\coincontroltreewidget.h -o %OUT_PATH%\moc_coincontroltreewidget.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\csvmodelwriter.h -o %OUT_PATH%\moc_csvmodelwriter.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\editaddressdialog.h -o %OUT_PATH%\moc_editaddressdialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\guiutil.h -o %OUT_PATH%\moc_guiutil.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\intro.h -o %OUT_PATH%\moc_intro.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\macdockiconhandler.h -o %OUT_PATH%\moc_macdockiconhandler.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\macnotificationhandler.h -o %OUT_PATH%\moc_macnotificationhandler.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\notificator.h -o %OUT_PATH%\moc_notificator.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\notificator.h -o %OUT_PATH%\moc_notificator.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\openuridialog.h -o %OUT_PATH%\moc_openuridialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\optionsdialog.h -o %OUT_PATH%\moc_optionsdialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\optionsmodel.h -o %OUT_PATH%\moc_optionsmodel.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\overviewpage.h -o %OUT_PATH%\moc_overviewpage.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\paymentserver.h -o %OUT_PATH%\moc_paymentserver.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\peertablemodel.h -o %OUT_PATH%\moc_peertablemodel.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\qvalidatedlineedit.h -o %OUT_PATH%\moc_qvalidatedlineedit.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\qvaluecombobox.h -o %OUT_PATH%\moc_qvaluecombobox.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\receivecoinsdialog.h -o %OUT_PATH%\moc_receivecoinsdialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\receiverequestdialog.h -o %OUT_PATH%\moc_receiverequestdialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\recentrequeststablemodel.h -o %OUT_PATH%\moc_recentrequeststablemodel.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\rpcconsole.h -o %OUT_PATH%\moc_rpcconsole.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\sendcoinsdialog.h -o %OUT_PATH%\moc_sendcoinsdialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\sendcoinsentry.h -o %OUT_PATH%\moc_sendcoinsentry.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\signverifymessagedialog.h -o %OUT_PATH%\moc_signverifymessagedialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\splashscreen.h -o %OUT_PATH%\moc_splashscreen.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\trafficgraphwidget.h -o %OUT_PATH%\moc_trafficgraphwidget.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\transactiondesc.h -o %OUT_PATH%\moc_transactiondesc.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\transactiondescdialog.h -o %OUT_PATH%\moc_transactiondescdialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\transactionfilterproxy.h -o %OUT_PATH%\moc_transactionfilterproxy.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\transactiontablemodel.h -o %OUT_PATH%\moc_transactiontablemodel.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\transactionview.h -o %OUT_PATH%\moc_transactionview.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\utilitydialog.h -o %OUT_PATH%\moc_utilitydialog.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\walletframe.h -o %OUT_PATH%\moc_walletframe.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\walletmodel.h -o %OUT_PATH%\moc_walletmodel.cpp
moc %MOC_DEF%  %SRC_PATH%\src\qt\walletview.h -o %OUT_PATH%\moc_walletview.cpp

moc %MOC_DEF%  %SRC_PATH%\src\qt\bitcoin.cpp -o %OUT_PATH%\bitcoin.moc
moc %MOC_DEF%  %SRC_PATH%\src\qt\bitcoinamountfield.cpp -o %OUT_PATH%\bitcoinamountfield.moc
moc %MOC_DEF%  %SRC_PATH%\src\qt\intro.cpp -o %OUT_PATH%\intro.moc
moc %MOC_DEF%  %SRC_PATH%\src\qt\overviewpage.cpp -o %OUT_PATH%\overviewpage.moc
moc %MOC_DEF%  %SRC_PATH%\src\qt\rpcconsole.cpp -o %OUT_PATH%\rpcconsole.moc

protoc -I=%SRC_PATH%\src\qt\ --cpp_out=%OUT_PATH%\ %SRC_PATH%\src\qt\paymentrequest.proto

rcc -name bitcoin %SRC_PATH%\src\qt\bitcoin.qrc -o %OUT_PATH%\qrc_bitcoin.cpp
rcc -name bitcoin_locale %SRC_PATH%\src\qt\bitcoin_locale.qrc -o %OUT_PATH%\qrc_bitcoin_locale.cpp
