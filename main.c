#include <gtk/gtk.h>

// 创建显示区域的函数
void show_content(GtkWidget *widget, gpointer data) {
    GtkWidget *label = GTK_WIDGET(data);
    const char *text = gtk_button_get_label(GTK_BUTTON(widget));
    gtk_label_set_text(GTK_LABEL(label), text);
}

// 主函数
int main(int argc, char *argv[]) {
    GtkWidget *window;
    GtkWidget *grid;
    GtkWidget *vbox;
    GtkWidget *hbox;
    GtkWidget *button1, *button2, *button3;
    GtkWidget *label;

    gtk_init(&argc, &argv);

    // 创建主窗口
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "左侧工具栏示例");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 300);

    // 创建网格布局
    grid = gtk_grid_new();
    gtk_container_add(GTK_CONTAINER(window), grid);

    // 创建工具栏区域（垂直盒子）
    vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    gtk_grid_attach(GTK_GRID(grid), vbox, 0, 0, 1, 1);

    // 创建显示区域
    label = gtk_label_new("请选择一个功能");
    gtk_grid_attach(GTK_GRID(grid), label, 1, 0, 1, 1);

    // 创建按钮并添加到工具栏
    button1 = gtk_button_new_with_label("proxychains");
    button2 = gtk_button_new_with_label("功能 2");
    button3 = gtk_button_new_with_label("功能 3");

    g_signal_connect(button1, "clicked", G_CALLBACK(show_content), label);
    g_signal_connect(button2, "clicked", G_CALLBACK(show_content), label);
    g_signal_connect(button3, "clicked", G_CALLBACK(show_content), label);

    gtk_box_pack_start(GTK_BOX(vbox), button1, TRUE, TRUE, 0);
    gtk_box_pack_start(GTK_BOX(vbox), button2, TRUE, TRUE, 0);
    gtk_box_pack_start(GTK_BOX(vbox), button3, TRUE, TRUE, 0);

    // 连接关闭信号
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

    gtk_widget_show_all(window);

    gtk_main();

    return 0;
}
