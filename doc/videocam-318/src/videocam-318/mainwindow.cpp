#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QTimer>
#include <QDebug>
#include <QPainter>
#include <QFont>

extern "C" {
#include "./../v4l2grab/v4l2grab.h"
}

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    setGeometry(0, 50, 1800, 600);

    setWindowTitle(" ");
    ui->lbCamImage->setText("");
    ui->lbTitleText->setText("");

    cams_ << "/dev/video0" << "/dev/video1" << "/dev/video2" << "/dev/video3";
    titles_ << "Третья позиция" << "Первая позиция" << "Вторая позиция"
            << "Четвертая позиция";

    id_ = 0;

    timerLoop_ = new QTimer;
    connect(timerLoop_, SIGNAL(timeout()), this, SLOT(loopTimerouted()));

    timerImage_ = new QTimer;
    connect(timerImage_, SIGNAL(timeout()), this, SLOT(imageTimerouted()));

    timerImage_->start(500);
}

MainWindow::~MainWindow()
{
    delete ui;
}

QPixmap MainWindow::getPixmap(const QString &deviceName)
{
    deviceOpen(deviceName.toAscii().data());
    deviceInit(deviceName.toAscii().data());
    captureStart();

    QString filename = "./temp.jpg";
    mainLoop(filename.toAscii().data());
    captureStop();
    deviceUninit();
    deviceClose();

    QPixmap pixmap;
    pixmap.load(filename);

    return pixmap;
}

void MainWindow::on_pbLoopVideoCams_clicked()
{
//    static int i = 0;
//    ui->lbCamImage->pixmap()->save(QString("./%0.jpg").arg(++i));
//    return;

    if (!timerLoop_->isActive()) {
        timerLoop_->start(3000);
        ui->pbLoopVideoCams->setText("НЕПРЕРЫВНО: ВКЛЮЧЕНО");
    } else {
        timerLoop_->stop();
        ui->pbLoopVideoCams->setText("НЕПРЕРЫВНО: ОТКЛЮЧЕНО");
    }
    ui->pbNextVideoCam->setEnabled(!ui->pbLoopVideoCams->isChecked());
    ui->pbPrevVideoCam->setEnabled(!ui->pbLoopVideoCams->isChecked());
}

void MainWindow::on_pbNextVideoCam_clicked()
{
    qDebug() << id_;

    if (id_ >= cams_.size() - 1) {
        id_ = 0;
    } else {
        ++id_;
    }

}

void MainWindow::loopTimerouted()
{
    on_pbNextVideoCam_clicked();
}

void MainWindow::imageTimerouted()
{
    ui->lbTitleText->setText(titles_.at(id_));
    QPixmap pixmap = getPixmap(cams_.at(id_));

    QPixmap pixmapDefect(":/image/defect.png");

    QPainter painter(&pixmap);

    if (id_ == 2) { // вторая позиция
        painter.drawPixmap(162, 174, pixmapDefect);
        painter.drawPixmap(274, 172, pixmapDefect);
        painter.drawPixmap(380, 164, pixmapDefect);
    } else if (id_ == 1) { // первая позиция
        painter.drawPixmap(124, 116, pixmapDefect);
        painter.drawPixmap(230, 154, pixmapDefect);
        painter.drawPixmap(320, 204, pixmapDefect);
    } else if (id_ == 0) { // третья позиция
        painter.drawPixmap(7, 163, pixmapDefect);
        painter.drawPixmap(483, 20, pixmapDefect);
        painter.drawPixmap(541, 135, pixmapDefect);
    } else if (id_ == 3) { // четверая позиция
        painter.drawPixmap(369, 94, pixmapDefect);
    }
    painter.end();

    pixmap = pixmap.scaledToHeight(
        ui->lbCamImage->height(), Qt::SmoothTransformation);
    ui->lbCamImage->setPixmap(pixmap);

}

void MainWindow::on_pbPrevVideoCam_clicked()
{
    qDebug() << id_;

    if (id_ <= 0) {
        id_ = cams_.size() - 1;
    } else {
        --id_;
    }
}
