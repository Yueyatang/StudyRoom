import promptAction from '@ohos.promptAction';

interface TodoItem {
  text: string;
  completed: boolean;
}

interface SceneData {
  name: string;
  bgColor: string;
  atmosphere: string;
  quote: string;
}

@Entry
@Component
struct StudyRoom {
  @State scenes: SceneData[] = [
    { name: '森林秘境', bgColor: '#2D5A3B', atmosphere: '🌲 松涛轻语 · 清新氧气', quote: '静听松风，心如止水' },
    { name: '海滨浪潮', bgColor: '#2A6B7C', atmosphere: '🌊 浪花白噪音 · 无垠海蓝', quote: '潮汐陪伴，沉浸于知识海洋' },
    { name: '城市夜景', bgColor: '#2C2E3E', atmosphere: '🌃 璀璨灯火 · 都市脉搏', quote: '万家灯火时，正是上进心' }
  ];

  @State currentSceneIndex: number = 0;
  @State totalSeconds: number = 25 * 60;
  @State timerDisplay: string = '25:00';
  @State isRunning: boolean = false;
  @State tomatoCount: number = 0;
  @State currentTime: string = '';
  @State todoList: TodoItem[] = [];
  @State newTodoText: string = '';

  private timerId: number = -1;
  private clockId: number = -1;

  aboutToAppear() {
    this.loadData();
    this.updateTimerDisplay();
    this.startClock();
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
    if (this.clockId !== -1) {
      clearInterval(this.clockId);
    }
  }

  startClock() {
    this.updateCurrentTime();
    this.clockId = setInterval(() => {
      this.updateCurrentTime();
    }, 1000);
  }

  updateCurrentTime() {
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    const seconds = now.getSeconds().toString().padStart(2, '0');
    this.currentTime = `${hours}:${minutes}:${seconds}`;
  }

  loadData() {
    try {
      const savedTomato = AppStorage.get<number>('tomatoCount');
      if (savedTomato !== undefined) {
        this.tomatoCount = savedTomato;
      }

      const savedTodos = AppStorage.get<string>('todoList');
      if (savedTodos !== undefined && savedTodos !== '') {
        const parsed: TodoItem[] = JSON.parse(savedTodos);
        if (Array.isArray(parsed)) {
          this.todoList = parsed;
        } else {
          this.initDefaultTodos();
        }
      } else {
        this.initDefaultTodos();
      }
    } catch (e) {
      this.initDefaultTodos();
    }
  }

  initDefaultTodos() {
    this.todoList = [
      { text: '深度阅读 30分钟', completed: false },
      { text: '复习笔记 2章', completed: false },
      { text: '撰写项目计划', completed: false }
    ];
    this.saveTodos();
  }

  saveTodos() {
    AppStorage.setOrCreate('todoList', JSON.stringify(this.todoList));
    AppStorage.setOrCreate('tomatoCount', this.tomatoCount);
  }

  updateTimerDisplay() {
    const mins = Math.floor(this.totalSeconds / 60);
    const secs = this.totalSeconds % 60;
    this.timerDisplay = `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;

    if (this.totalSeconds === 0 && this.isRunning) {
      this.stopTimer();
      this.tomatoCount = this.tomatoCount + 1;
      this.saveTodos();
      promptAction.showToast({
        message: '🎉 专注完成！番茄+1',
        duration: 2000
      });
    }
  }

  startTimer() {
    if (this.timerId !== -1) {
      return;
    }
    if (this.totalSeconds <= 0) {
      this.totalSeconds = 25 * 60;
      this.updateTimerDisplay();
    }
    this.isRunning = true;
    this.timerId = setInterval(() => {
      if (this.totalSeconds > 0 && this.isRunning) {
        this.totalSeconds = this.totalSeconds - 1;
        this.updateTimerDisplay();
      }
    }, 1000);
  }

  stopTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.isRunning = false;
  }

  pauseTimer() {
    this.stopTimer();
  }

  resetTimer() {
    this.stopTimer();
    this.totalSeconds = 25 * 60;
    this.updateTimerDisplay();
  }

  addMinutes(minutes: number) {
    let newSec = this.totalSeconds + minutes * 60;
    if (newSec < 0) {
      newSec = 0;
    }
    if (newSec > 7200) {
      newSec = 7200;
    }
    this.totalSeconds = newSec;
    this.updateTimerDisplay();
  }

  switchScene(index: number) {
    this.currentSceneIndex = index;
  }

  toggleTodo(index: number) {
    this.todoList[index].completed = !this.todoList[index].completed;
    this.saveTodos();
  }

  addTodo() {
    if (this.newTodoText.trim() === '') {
      return;
    }
    const newItem: TodoItem = {
      text: this.newTodoText,
      completed: false
    };
    this.todoList.push(newItem);
    this.newTodoText = '';
    this.saveTodos();
  }

  deleteTodo(index: number) {
    this.todoList.splice(index, 1);
    this.saveTodos();
  }

  build() {
    Stack() {
      // 1. 背景层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.scenes[this.currentSceneIndex].bgColor)

      // 2. 内容层：使用 Column 自动分配高度
      Column() {
        // 状态栏占位（使用固定数值，不再使用无效的 CSS 变量）
        Row()
          .height(24)  // ✅ 修改：固定高度
          .width('100%')

        // 滚动区域：使用 layoutWeight 填充剩余空间
        Scroll() {
          Column() {
            // 场景切换按钮
            Row() {
              ForEach(this.scenes, (scene: SceneData, index: number) => {
                Text(scene.name)
                  .fontSize(14)
                  .fontColor(this.currentSceneIndex === index ? '#FFD878' : '#FFFFFF')
                  .fontWeight(this.currentSceneIndex === index ? FontWeight.Bold : FontWeight.Normal)
                  .width('33%')
                  .height(44)
                  .textAlign(TextAlign.Center)
                  .borderRadius(22)
                  .backgroundColor(this.currentSceneIndex === index ? 'rgba(255,216,120,0.25)' : 'rgba(255,255,255,0.1)')
                  .onClick(() => {
                    this.switchScene(index);
                  })
              })
            }
            .width('90%')
            .margin({ top: 16, bottom: 12 })

            // 氛围文字
            Text(this.scenes[this.currentSceneIndex].atmosphere)
              .fontSize(12)
              .fontColor('#E0E0E0')
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor('rgba(0,0,0,0.2)')
              .borderRadius(40)
              .margin({ bottom: 16 })

            // 计时器卡片
            Column() {
              Text(this.timerDisplay)
                .fontSize(56)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .fontFamily('monospace')
                .letterSpacing(6)
                .margin({ top: 12, bottom: 12 })

              Row() {
                Button('开始')
                  .fontSize(14)
                  .height(38)
                  .padding({ left: 20, right: 20 })
                  .backgroundColor('rgba(100,120,200,0.8)')
                  .borderRadius(38)
                  .onClick(() => {
                    this.startTimer();
                  })

                Button('暂停')
                  .fontSize(14)
                  .height(38)
                  .padding({ left: 20, right: 20 })
                  .backgroundColor('rgba(60,60,80,0.8)')
                  .borderRadius(38)
                  .margin({ left: 10 })
                  .onClick(() => {
                    this.pauseTimer();
                  })

                Button('重置')
                  .fontSize(14)
                  .height(38)
                  .padding({ left: 20, right: 20 })
                  .backgroundColor('rgba(60,60,80,0.8)')
                  .borderRadius(38)
                  .margin({ left: 10 })
                  .onClick(() => {
                    this.resetTimer();
                  })
              }

              Row() {
                Button('-5')
                  .fontSize(12)
                  .height(34)
                  .backgroundColor('rgba(45,50,65,0.8)')
                  .borderRadius(34)
                  .layoutWeight(1)
                  .onClick(() => {
                    this.addMinutes(-5);
                  })

                Button('+5')
                  .fontSize(12)
                  .height(34)
                  .backgroundColor('rgba(45,50,65,0.8)')
                  .borderRadius(34)
                  .layoutWeight(1)
                  .margin({ left: 12 })
                  .onClick(() => {
                    this.addMinutes(5);
                  })
              }
              .width('100%')
              .margin({ top: 10, bottom: 10 })
            }
            .width('90%')
            .backgroundColor('rgba(30,34,48,0.6)')
            .borderRadius(28)
            .padding(16)
            .margin({ bottom: 16 })

            // 番茄统计
            Row() {
              Text('🍅 今日番茄钟')
                .fontSize(14)
                .fontColor('#CCCCCC')
              Blank()
              Text(`${this.tomatoCount}`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFB347')
            }
            .width('90%')
            .backgroundColor('rgba(0,0,0,0.25)')
            .borderRadius(22)
            .padding({ left: 18, right: 18, top: 10, bottom: 10 })
            .margin({ bottom: 16 })

            // 待办清单卡片
            Column() {
              Row() {
                Text('📝 沉浸待办')
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
                    .onChange((val: boolean) => {
                      this.toggleTodo(index);
                    })
                  Text(item.text)
                    .fontSize(14)
                    .fontColor(item.completed ? '#888888' : '#EEEEEE')
                    .decoration({ type: item.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
                    .margin({ left: 8 })
                    .layoutWeight(1)
                  Button('删')
                    .fontSize(11)
                    .height(26)
                    .backgroundColor('rgba(255,255,255,0.15)')
                    .borderRadius(13)
                    .onClick(() => {
                      this.deleteTodo(index);
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
                    this.newTodoText = value;
                  })
                Button('+')
                  .fontSize(18)
                  .height(38)
                  .width(42)
                  .backgroundColor('rgba(255,180,70,0.8)')
                  .borderRadius(20)
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.addTodo();
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
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .backgroundColor('rgba(0,0,0,0)')
        .scrollBar(BarState.Off)
        .width('100%')
        .layoutWeight(1)  // ✅ 关键修改：替代原来的 height('100%')，配合父 Column 分配剩余空间

        // 底部信息栏
        Row() {
          Text(this.currentTime)
            .fontSize(13)
            .fontColor('#CCCCCC')
            .padding({ left: 14, right: 14, top: 5, bottom: 5 })
            .backgroundColor('rgba(0,0,0,0.3)')
            .borderRadius(22)

          Blank()

          Text(this.scenes[this.currentSceneIndex].quote)
            .fontSize(11)
            .fontColor('#BBBBBB')
            .fontStyle(FontStyle.Italic)
            .maxLines(1)
            .padding({ left: 14, right: 14, top: 5, bottom: 5 })
            .backgroundColor('rgba(0,0,0,0.3)')
            .borderRadius(22)
        }
        .width('90%')
        .margin({ bottom: 16 })
        .padding({ top: 6, bottom: 6 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}