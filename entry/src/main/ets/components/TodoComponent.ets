import { TodoItem } from '../common/StudyRoomTypes';
import promptAction from '@ohos.promptAction';   // 新增导入

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

  getProgress(): number {
    if (this.todoList.length === 0) {
      return 0;
    }
    return this.getCompletedCount() / this.todoList.length;
  }

  getEncouragement(): string {
    const rate = this.getProgress();
    if (rate === 0) {
      return '今天也要加油哦！';
    } else if (rate < 0.3) {
      return '好的开始是成功的一半！';
    } else if (rate < 0.6) {
      return '继续保持，你正在进步！';
    } else if (rate < 0.9) {
      return '太棒了，即将完成！';
    } else if (rate < 1) {
      return '就差最后一步了！';
    } else {
      return '完美！你已超越自己！';
    }
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

  // 删除确认弹窗
  private showDeleteConfirm(index: number) {
    promptAction.showDialog({
      title: '确认删除',
      message: '确定要删除该任务吗？',
      buttons: [
        {
          text: '取消',
          color: '#999999'
        },
        {
          text: '删除',
          color: '#FF6B6B'
        }
      ]
    }).then((result) => {
      if (result.index === 1) { // 点击“删除”按钮（索引为1）
        this.onDelete(index);
      }
    }).catch((err: Error) => {
      console.error(`[TodoComponent] showDialog error: ${JSON.stringify(err)}`);
    });
  }

  @Builder
  taskRow(item: TodoItem, index: number) {
    Row() {
      // 完成状态按钮
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(26)
          .height(26)
          .stroke(item.completed ? '#FFD878' : 'rgba(255,255,255,0.3)')
          .strokeWidth(2.5)
          .fill(item.completed ? '#FFD878' : 'transparent')

        if (item.completed) {
          Text('✓')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1B2431')
        }
      }
      .width(26)
      .height(26)
      .onClick(() => {
        this.onToggle(index);
      })

      // 任务文本
      Column() {
        Row() {
          Text(item.text)
            .fontSize(15)
            .fontColor(item.completed ? 'rgba(196,202,208,0.5)' : '#F4F7FA')
            .decoration({
              type: item.completed ? TextDecorationType.LineThrough : TextDecorationType.None
            })
            .fontWeight(item.pinned && !item.completed ? FontWeight.Medium : FontWeight.Normal)

          if (item.pinned && !item.completed) {
            Text('置顶')
              .fontSize(9)
              .fontColor('#FFD878')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor('rgba(255,216,120,0.15)')
              .borderRadius(10)
              .margin({ left: 8 })
          }
        }

        if (item.completed) {
          Text('已完成')
            .fontSize(10)
            .fontColor('rgba(196,202,208,0.4)')
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        if (!item.completed) {
          this.onToggle(index);
        }
      })

      // 右侧操作按钮
      Row() {
        if (!item.completed) {
          Button(item.pinned ? '取消置顶' : '置顶')
            .fontSize(11)
            .fontColor(item.pinned ? '#FFD878' : 'rgba(255,255,255,0.6)')
            .height(30)
            .padding({ left: 10, right: 10 })
            .backgroundColor(item.pinned ? 'rgba(255,216,120,0.2)' : 'rgba(255,255,255,0.06)')
            .borderRadius(15)
            .onClick(() => {
              this.onPin(index);
            })
        }

        Button('删除')
          .fontSize(11)
          .fontColor('rgba(255,255,255,0.5)')
          .height(30)
          .padding({ left: 10, right: 10 })
          .backgroundColor('rgba(255,255,255,0.06)')
          .borderRadius(15)
          .margin({ left: 6 })
          .onClick(() => {
            this.showDeleteConfirm(index);   // 弹窗确认后再删除
          })
      }
    }
    .width('100%')
    .padding({ left: 14, right: 12, top: 10, bottom: 10 })
    .backgroundColor(
      item.completed
        ? 'rgba(255,255,255,0.03)'
        : item.pinned
        ? 'rgba(255,216,120,0.08)'
        : 'rgba(255,255,255,0.05)'
    )
    .borderRadius(16)
    .border({
      width: item.pinned && !item.completed ? 1 : 0,
      color: 'rgba(255,216,120,0.15)'
    })
    .margin({ bottom: 8 })
  }

  build() {
    Column() {
      // 头部
      Row() {
        Column() {
          Text('学习清单')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text(this.getEncouragement())
            .fontSize(13)
            .fontColor('rgba(255,216,120,0.8)')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(52)
            .height(52)
            .stroke('rgba(255,255,255,0.08)')
            .strokeWidth(4)
            .fill('transparent')

          Circle()
            .width(52)
            .height(52)
            .stroke('#FFD878')
            .strokeWidth(4)
            .fill('transparent')
            .strokeDashArray([Math.PI * 52, Math.PI * 52])
            .strokeDashOffset((1 - this.getProgress()) * Math.PI * 52)
            .rotate({ angle: -90 })

          Text(`${Math.round(this.getProgress() * 100)}%`)
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
      }
      .width('100%')
      .margin({ bottom: 14 })

      // 进度条
      Column() {
        Row() {
          Text(`已完成 ${this.getCompletedCount()} 项`)
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.6)')

          Blank()

          Text(`共 ${this.todoList.length} 项`)
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.4)')
        }
        .width('100%')
        .margin({ bottom: 6 })

        Row() {
          Row()
            .width(`${this.getProgress() * 100}%`)
            .height(4)
            .backgroundColor('#FFD878')
            .borderRadius(2)
        }
        .width('100%')
        .height(4)
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(2)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 添加输入框
      Row() {
        TextInput({ placeholder: '添加新的学习目标...', text: this.newTodoText })
          .placeholderColor('rgba(255,255,255,0.3)')
          .fontSize(14)
          .fontColor('#F4F7FA')
          .height(46)
          .layoutWeight(1)
          .backgroundColor('rgba(255,255,255,0.06)')
          .borderRadius(23)
          .padding({ left: 18, right: 18 })
          .onChange((value: string) => {
            this.onTextChange(value);
          })
          .onSubmit(() => {
            this.onAdd();
          })

        Button('添加')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1B2431')
          .height(46)
          .padding({ left: 20, right: 20 })
          .backgroundColor('#FFD878')
          .borderRadius(23)
          .margin({ left: 10 })
          .onClick(() => {
            this.onAdd();
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 未完成任务
      if (this.getPendingIndexes().length > 0) {
        Column() {
          Row() {
            Text(`进行中 (${this.getPendingIndexes().length})`)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(255,255,255,0.7)')
          }
          .width('100%')
          .margin({ bottom: 10 })

          ForEach(this.getPendingIndexes(), (index: number) => {
            this.taskRow(this.todoList[index], index)
          })
        }
        .width('100%')
      }

      // 全部完成状态
      if (this.getPendingIndexes().length === 0 && this.todoList.length > 0) {
        Column() {
          Text('🎉')
            .fontSize(48)
            .margin({ bottom: 8 })

          Text('所有任务都完成了！')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')

          Text('你太棒了，休息一下吧')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.4)')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ top: 24, bottom: 24 })
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('rgba(255,255,255,0.02)')
        .borderRadius(16)
        .margin({ bottom: 10 })
      }

      // 空状态
      if (this.todoList.length === 0) {
        Column() {
          Text('📋')
            .fontSize(48)
            .margin({ bottom: 8 })

          Text('还没有学习目标')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(255,255,255,0.5)')

          Text('在上方添加你的第一个目标吧')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.3)')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ top: 32, bottom: 32 })
        .alignItems(HorizontalAlign.Center)
      }

      // 已完成（折叠）
      if (this.getCompletedIndexes().length > 0) {
        Column() {
          Row() {
            Text(`已完成 (${this.getCompletedIndexes().length})`)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(255,255,255,0.5)')

            Blank()

            Button(this.showCompleted ? '收起' : '展开')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.5)')
              .height(28)
              .padding({ left: 14, right: 14 })
              .backgroundColor('rgba(255,255,255,0.06)')
              .borderRadius(14)
              .onClick(() => {
                this.onToggleCompletedSection();
              })
          }
          .width('100%')
          .padding({ top: 12, bottom: 8 })

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
        .margin({ top: 4 })
        .border({
          width: { top: 1 },
          color: 'rgba(255,255,255,0.05)'
        })
      }
    }
    .width('90%')
    .backgroundColor('rgba(22,28,38,0.75)')
    .borderRadius(30)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .border({
      width: 1,
      color: 'rgba(255,255,255,0.06)'
    })
    .backdropBlur(10)
    .margin({ bottom: 40 })
  }
}