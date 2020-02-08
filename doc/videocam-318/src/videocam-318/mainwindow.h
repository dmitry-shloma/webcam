#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QStringList>
#include <QPixmap>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

    QPixmap getPixmap(const QString &deviceName);

private slots:
    void on_pbLoopVideoCams_clicked();
    void on_pbNextVideoCam_clicked();
    void loopTimerouted();
    void imageTimerouted();
    void on_pbPrevVideoCam_clicked();

private:
    Ui::MainWindow *ui;

    QStringList cams_;
    QStringList titles_;

    QTimer *timerLoop_;
    QTimer *timerImage_;
    int id_;
};

#endif // MAINWINDOW_H
