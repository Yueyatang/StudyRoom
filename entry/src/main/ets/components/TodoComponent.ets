import { TodoItem } from '../common/StudyRoomTypes';

@Component
export struct TodoComponent {
  @Prop todoList: TodoItem[] = [];
  @Prop newTodoText: string = '';
  onToggle: (index: number) => void = () => {};
  onDelete: (index: number) => void = () => {};
  onTextChange: (value: string) => void = () => {};
  onAdd: () => void = () => {};

  build() {
    Column() {
      Row() {
        Text('待办清单')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
        Blank()
      }
      .width('100%')
      .margin({ bottom: 10 })

      ForEach(this.todoList, (item: TodoItem, index: number) => {
        Row() {
          Checkbox()
            .select(item.completed)
            .onChange(() => {
              this.onToggle(index);
            })
          Text(item.text)
            .fontSize(14)
            .fontColor(item.completed ? '#888888' : '#EEEEEE')
            .decoration({ type: item.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
            .margin({ left: 8 })
            .layoutWeight(1)
          Button('删除')
            .fontSize(11)
            .height(26)
            .backgroundColor('rgba(255,255,255,0.15)')
            .borderRadius(13)
            .onClick(() => {
              this.onDelete(index);
            })
        }
        .width('100%')
        .margin({ bottom: 6 })
      })

      Row() {
        TextInput({ placeholder: '添加新任务...', text: this.newTodoText })
          .fontSize(14)
          .height(38)
          .layoutWeight(1)
          .backgroundColor('rgba(255,255,255,0.15)')
          .borderRadius(20)
          .padding({ left: 14 })
          .onChange((value: string) => {
            this.onTextChange(value);
          })
        Button('+')
          .fontSize(18)
          .height(38)
          .width(42)
          .backgroundColor('rgba(255,180,70,0.8)')
          .borderRadius(20)
          .margin({ left: 8 })
          .onClick(() => {
            this.onAdd();
          })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('90%')
    .backgroundColor('rgba(30,34,48,0.6)')
    .borderRadius(28)
    .padding(16)
    .margin({ bottom: 40 })
  }
}
