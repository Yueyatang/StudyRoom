import { TodoItem } from '../common/StudyRoomTypes';

@Component
export struct TodoComponent {
  @Prop todoList: TodoItem[] = [];
  @Prop newTodoText: string = '';
  onToggle: (index: number) => void = () => {};
  onDelete: (index: number) => void = () => {};
  onTextChange: (value: string) => void = () => {};
  onAdd: () => void = () => {};

  getCompletedCount(): number {
    let count = 0;
    this.todoList.forEach((item: TodoItem) => {
      if (item.completed) {
        count = count + 1;
      }
    });
    return count;
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('学习清单')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('把今天最重要的学习目标拆成几步完成。')
            .fontSize(12)
            .fontColor('rgba(233,238,243,0.72)')
            .margin({ top: 6 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text('已完成')
            .fontSize(10)
            .fontColor('rgba(229,235,240,0.62)')
          Text(`${this.getCompletedCount()}/${this.todoList.length}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F7D28F')
            .margin({ top: 4 })
        }
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(18)
      }
      .width('100%')
      .margin({ bottom: 14 })

      Row() {
        TextInput({ placeholder: '添加一个学习目标', text: this.newTodoText })
          .placeholderColor('rgba(229,235,240,0.46)')
          .fontSize(14)
          .fontColor('#F4F7FA')
          .height(44)
          .layoutWeight(1)
          .backgroundColor('rgba(255,255,255,0.10)')
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.onTextChange(value);
          })

        Button('添加')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .height(44)
          .padding({ left: 18, right: 18 })
          .backgroundColor('#E0A95B')
          .borderRadius(22)
          .margin({ left: 10 })
          .onClick(() => {
            this.onAdd();
          })
      }
      .width('100%')
      .margin({ bottom: 14 })

      ForEach(this.todoList, (item: TodoItem, index: number) => {
        Row() {
          Stack({ alignContent: Alignment.Center }) {
            Circle()
              .width(22)
              .height(22)
              .stroke(item.completed ? '#E0B56D' : 'rgba(229,235,240,0.48)')
              .strokeWidth(2)
              .fill(item.completed ? '#E0B56D' : 'rgba(255,255,255,0.02)')

            if (item.completed) {
              Text('✓')
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1B2431')
            }
          }
          .width(22)
          .height(22)
          .onClick(() => {
            this.onToggle(index);
          })

          Text(item.text)
            .fontSize(14)
            .fontColor(item.completed ? 'rgba(196,202,208,0.62)' : '#F4F7FA')
            .decoration({ type: item.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
            .margin({ left: 10 })
            .layoutWeight(1)
            .onClick(() => {
              this.onToggle(index);
            })

          Text(item.completed ? '已完成' : '未完成')
            .fontSize(10)
            .fontColor(item.completed ? '#D6E8C8' : '#FFDFA3')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(item.completed ? 'rgba(146,182,121,0.20)' : 'rgba(224,169,91,0.16)')
            .borderRadius(12)
            .margin({ left: 8, right: 8 })
            .onClick(() => {
              this.onToggle(index);
            })

          Button('删除')
            .fontSize(11)
            .fontColor('#F5F7FA')
            .height(28)
            .padding({ left: 12, right: 12 })
            .backgroundColor('rgba(255,255,255,0.12)')
            .borderRadius(14)
            .onClick(() => {
              this.onDelete(index);
            })
        }
        .width('100%')
        .padding({ left: 14, right: 12, top: 12, bottom: 12 })
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(20)
        .margin({ bottom: 10 })
      }, (item: TodoItem) => `${item.id}_${item.completed ? '1' : '0'}`)
    }
    .width('90%')
    .backgroundColor('rgba(22,28,38,0.64)')
    .borderRadius(30)
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .border({
      width: 1,
      color: 'rgba(255,255,255,0.08)'
    })
    .margin({ bottom: 40 })
  }
}
