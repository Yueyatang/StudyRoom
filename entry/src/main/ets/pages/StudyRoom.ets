import promptAction from '@ohos.promptAction';
import { SceneSelector } from '../components/SceneSelector';
import { TimerComponent } from '../components/TimerComponent';
import { TodoComponent } from '../components/TodoComponent';
import { SceneData, TimerMode, TodoItem } from '../common/StudyRoomTypes';

@Entry
@Component
struct StudyRoom {
  @State scenes: SceneData[] = [
    { name: '森林秘境', bgColor: '#2D5A3B', atmosphere: '松风轻语 · 清新氧气', quote: '静听松风，心如止水' },
    { name: '海岸潮汐', bgColor: '#2A6B7C', atmosphere: '浪花白噪音 · 无垠海蓝', quote: '潮汐相伴，沉浸于知识海洋' },
    { name: '城市夜景', bgColor: '#2C2E3E', atmosphere: '霓虹灯火 · 都市脉搏', quote: '万家灯火时，正是精进时' }
  ];

  @State currentSceneIndex: number = 0;
  @State totalSeconds: number = 25 * 60;
  @State timerDisplay: string = '25:00';
  @State isRunning: boolean = false;
  @State tomatoCount: number = 0;
  @State currentTime: string = '';
  @State todoList: TodoItem[] = [];
  @State newTodoText: string = '';
  @State currentMode: TimerMode = 'focus';
  @State focusDuration: number = 25 * 60;
  @State shortBreakDuration: number = 5 * 60;
  @State longBreakDuration: number = 15 * 60;
  @State completedFocusSessions: number = 0;
  @State totalFocusMinutes: number = 0;
  @State currentSessionTotalSeconds: number = 25 * 60;

  private timerId: number = -1;
  private clockId: number = -1;

  aboutToAppear() {
    this.loadData();
    this.applyCurrentModeDuration();
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
          return;
        }
      }
      this.initDefaultTodos();
    } catch (e) {
      this.initDefaultTodos();
    }
  }

  initDefaultTodos() {
    this.todoList = [
      { text: '深度阅读 30 分钟', completed: false },
      { text: '复习笔记 2 章', completed: false },
      { text: '整理项目计划', completed: false }
    ];
    this.saveTodos();
  }

  saveTodos() {
    AppStorage.setOrCreate('todoList', JSON.stringify(this.todoList));
    AppStorage.setOrCreate('tomatoCount', this.tomatoCount);
  }

  getDurationForMode(mode: TimerMode): number {
    if (mode === 'focus') {
      return this.focusDuration;
    }
    if (mode === 'shortBreak') {
      return this.shortBreakDuration;
    }
    return this.longBreakDuration;
  }

  getModeLabel(mode: TimerMode): string {
    if (mode === 'focus') {
      return 'Focus';
    }
    if (mode === 'shortBreak') {
      return 'Short Break';
    }
    return 'Long Break';
  }

  applyCurrentModeDuration() {
    this.totalSeconds = this.getDurationForMode(this.currentMode);
    this.currentSessionTotalSeconds = this.totalSeconds;
    this.updateTimerDisplay();
  }

  updateTimerDisplay() {
    const mins = Math.floor(this.totalSeconds / 60);
    const secs = this.totalSeconds % 60;
    this.timerDisplay = `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;

    if (this.totalSeconds === 0 && this.isRunning) {
      this.completeCurrentSession();
    }
  }

  completeCurrentSession() {
    this.stopTimer();
    if (this.currentMode === 'focus') {
      this.tomatoCount = this.tomatoCount + 1;
      this.completedFocusSessions = this.completedFocusSessions + 1;
      this.totalFocusMinutes = this.totalFocusMinutes + Math.floor(this.currentSessionTotalSeconds / 60);
      this.saveTodos();

      const nextMode: TimerMode = this.completedFocusSessions % 4 === 0 ? 'longBreak' : 'shortBreak';
      this.switchMode(nextMode, true);
      promptAction.showToast({
        message: `专注完成，接下来进入${this.getModeLabel(nextMode)}`,
        duration: 2000
      });
      return;
    }

    this.switchMode('focus', true);
    promptAction.showToast({
      message: '休息结束，回到专注',
      duration: 2000
    });
  }

  startTimer() {
    if (this.timerId !== -1) {
      return;
    }
    if (this.totalSeconds <= 0) {
      this.applyCurrentModeDuration();
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
    this.applyCurrentModeDuration();
  }

  addMinutes(minutes: number) {
    let newSeconds = this.totalSeconds + minutes * 60;
    if (newSeconds < 0) {
      newSeconds = 0;
    }
    if (newSeconds > 7200) {
      newSeconds = 7200;
    }

    if (this.currentMode === 'focus') {
      this.focusDuration = newSeconds;
    } else if (this.currentMode === 'shortBreak') {
      this.shortBreakDuration = newSeconds;
    } else {
      this.longBreakDuration = newSeconds;
    }

    this.totalSeconds = newSeconds;
    this.currentSessionTotalSeconds = newSeconds;
    this.updateTimerDisplay();
  }

  switchMode(mode: TimerMode, autoStart: boolean = false) {
    this.stopTimer();
    this.currentMode = mode;
    this.applyCurrentModeDuration();
    if (autoStart) {
      this.startTimer();
    }
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
    this.todoList.push({
      text: this.newTodoText,
      completed: false
    });
    this.newTodoText = '';
    this.saveTodos();
  }

  deleteTodo(index: number) {
    this.todoList.splice(index, 1);
    this.saveTodos();
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.scenes[this.currentSceneIndex].bgColor)

      Column() {
        Row()
          .height(24)
          .width('100%')

        Scroll() {
          Column() {
            SceneSelector({
              scenes: this.scenes,
              currentSceneIndex: this.currentSceneIndex,
              onSceneChange: (index: number) => {
                this.switchScene(index);
              }
            })

            TimerComponent({
              timerDisplay: this.timerDisplay,
              currentMode: this.currentMode,
              isRunning: this.isRunning,
              completedFocusSessions: this.completedFocusSessions,
              totalFocusMinutes: this.totalFocusMinutes,
              onStart: () => {
                this.startTimer();
              },
              onPause: () => {
                this.pauseTimer();
              },
              onReset: () => {
                this.resetTimer();
              },
              onAdjustMinutes: (minutes: number) => {
                this.addMinutes(minutes);
              },
              onSelectMode: (mode: TimerMode) => {
                this.switchMode(mode);
              }
            })

            Row() {
              Text('今日番茄数')
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

            TodoComponent({
              todoList: this.todoList,
              newTodoText: this.newTodoText,
              onToggle: (index: number) => {
                this.toggleTodo(index);
              },
              onDelete: (index: number) => {
                this.deleteTodo(index);
              },
              onTextChange: (value: string) => {
                this.newTodoText = value;
              },
              onAdd: () => {
                this.addTodo();
              }
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .backgroundColor('rgba(0,0,0,0)')
        .scrollBar(BarState.Off)
        .width('100%')
        .layoutWeight(1)

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
