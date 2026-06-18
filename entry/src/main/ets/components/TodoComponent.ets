import { TodoItem } from '../common/StudyRoomTypes';

@Component
export struct TodoComponent {
  @Prop todoList: TodoItem[] = [];
  @Prop newTodoText: string = '';
  @Prop showCompleted: boolean = false;
  onToggle: (index: number) => void = () => {};
  onDelete: (index: number) => void = () => {};
  onTextChange: (value: string) => void = () => {};
  onAdd: () => void = () => {};
  onToggleCompletedSection: () => void = () => {};
  onPin: (index: number) => void = () => {};

  getCompletedCount(): number {
    let count = 0;
    this.todoList.forEach((item: TodoItem) => {
      if (item.completed) {
        count = count + 1;
      }
    });
    return count;
  }

  getPendingIndexes(): number[] {
    const indexes: number[] = [];
    this.todoList.forEach((item: TodoItem, index: number) => {
      if (!item.completed) {
        indexes.push(index);
      }
    });
    indexes.sort((leftIndex: number, rightIndex: number) => {
      const leftItem = this.todoList[leftIndex];
      const rightItem = this.todoList[rightIndex];
      if (leftItem.pinned === rightItem.pinned) {
        return leftIndex - rightIndex;
      }
      return leftItem.pinned ? -1 : 1;
    });
    return indexes;
  }

  getCompletedIndexes(): number[] {
    const indexes: number[] = [];
    this.todoList.forEach((item: TodoItem, index: number) => {
      if (item.completed) {
        indexes.push(index);
      }
    });
    return indexes;
  }

  @Builder
  taskRow(item: TodoItem, index: number) {
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

      Column() {
        Text(item.text)
          .fontSize(14)
          .fontColor(item.completed ? 'rgba(196,202,208,0.62)' : '#F4F7FA')
          .decoration({ type: item.completed ? TextDecorationType.LineThrough : TextDecorationType.None })

        if (item.pinned && !item.completed) {
          Text('已置顶')
            .fontSize(10)
            .fontColor('#FFDFA3')
            .margin({ top: 4 })
        }
      }
      .layoutWeight(1)
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        this.onToggle(index);
      })

      Button(item.pinned && !item.completed ? '取消置顶' : '置顶')
        .fontSize(10)
        .fontColor('#F5F7FA')
        .height(28)
        .padding({ left: 10, right: 10 })
        .backgroundColor(item.pinned && !item.completed ? 'rgba(224,181,109,0.24)' : 'rgba(255,255,255,0.12)')
        .borderRadius(14)
        .margin({ right: 8 })
        .enabled(!item.completed)
        .opacity(item.completed ? 0.45 : 1)
        .onClick(() => {
          if (!item.completed) {
            this.onPin(index);
          }
        })

      Text(item.completed ? '已完成' : '未完成')
        .fontSize(10)
        .fontColor(item.completed ? '#D6E8C8' : '#FFDFA3')
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor(item.completed ? 'rgba(146,182,121,0.20)' : 'rgba(224,169,91,0.16)')
        .borderRadius(12)
        .margin({ right: 8 })
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

      if (this.getPendingIndexes().length > 0) {
        Column() {
          ForEach(this.getPendingIndexes(), (index: number) => {
            this.taskRow(this.todoList[index], index)
          })
        }
        .width('100%')
      }

      if (this.getPendingIndexes().length === 0) {
        Text('当前没有未完成任务，可以查看下方已完成内容。')
          .width('100%')
          .fontSize(12)
          .fontColor('rgba(233,238,243,0.64)')
          .padding({ top: 8, bottom: 14 })
      }

      if (this.getCompletedIndexes().length > 0) {
        Column() {
          Row() {
            Text(`已完成任务 ${this.getCompletedIndexes().length}`)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F3F5F8')

            Blank()

            Button(this.showCompleted ? '收起' : '展开')
              .fontSize(11)
              .fontColor('#F5F7FA')
              .height(30)
              .padding({ left: 12, right: 12 })
              .backgroundColor('rgba(255,255,255,0.10)')
              .borderRadius(15)
              .onClick(() => {
                this.onToggleCompletedSection();
              })
          }
          .width('100%')
          .padding({ top: 6, bottom: 10 })

          if (this.showCompleted) {
            Column() {
              ForEach(this.getCompletedIndexes(), (index: number) => {
                this.taskRow(this.todoList[index], index)
              })
            }
            .width('100%')
          }
        }
        .width('100%')
        .margin({ top: 8 })
      }
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
