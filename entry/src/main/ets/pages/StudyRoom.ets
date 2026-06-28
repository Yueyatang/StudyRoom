import promptAction from '@ohos.promptAction';
import media from '@ohos.multimedia.media';
import preferences from '@ohos.data.preferences';
import { SceneSelector } from '../components/SceneSelector';
import { TimerComponent } from '../components/TimerComponent';
import { TodoComponent } from '../components/TodoComponent';
import { CompanionComponent } from '../components/CompanionComponent';   // 新增
import { SceneData, TimerMode, TodoItem } from '../common/StudyRoomTypes';

@Entry
@Component
struct StudyRoom {
  @State scenes: SceneData[] = [
    {
      name: '森林秘境',
      bgColor: '#2D5A3B',
      accentColor: 'rgba(94, 164, 112, 0.45)',
      atmosphere: '松风轻语，空气清润，适合安静沉浸。',
      quote: '静听松风，心如止水。',
      suggestion: '深度阅读',
      musicLabel: '森林沉浸音乐',
      soundLabel: '鸟鸣环境音',
      imageName: 'forest2.jpg',
      musicName: 'forest_music.mp3',
      soundName: 'forest_bird_sound.wav'
    },
    {
      name: '海岸潮汐',
      bgColor: '#2A6B7C',
      accentColor: 'rgba(72, 153, 181, 0.45)',
      atmosphere: '浪声有节律，能帮你把注意力拉回当下。',
      quote: '潮汐相伴，沉浸于知识海洋。',
      suggestion: '背诵记忆',
      musicLabel: '海边沉浸音乐',
      soundLabel: '海浪环境音',
      imageName: 'sea1.jpg',
      musicName: 'sea_music1.mp3',
      soundName: 'sea_sound.wav'
    },
    {
      name: '城市夜景',
      bgColor: '#2C2E3E',
      accentColor: 'rgba(116, 126, 196, 0.40)',
      atmosphere: '夜色安静克制，适合进入稳定高效的节奏。',
      quote: '万家灯火时，正是精进时。',
      suggestion: '写作输出',
      musicLabel: '城市夜曲',
      soundLabel: '车流环境音',
      imageName: 'night_city2.jpg',
      musicName: 'city_music.mp3',
      soundName: 'city_sound.wav'
    }
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
  @State totalFocusSeconds: number = 0;
  @State currentSessionTotalSeconds: number = 25 * 60;
  @State backgroundOverlayOpacity: number = 0.28;
  @State sceneInfoScale: number = 1;
  @State musicEnabled: boolean = true;
  @State soundEnabled: boolean = true;
  @State showCompletedTodos: boolean = false;

  // ----- 陪伴系统新增状态 -----
  @State continuousDays: number = 0;
  @State totalTomatoCount: number = 0;
  @State lastActiveDate: string = '';

  private timerId: number = -1;
  private clockId: number = -1;
  private musicPlayer: media.AVPlayer | null = null;
  private musicRawFd: media.AVFileDescriptor | null = null;
  private activeMusicName: string = '';
  private isPreparingMusic: boolean = false;
  private musicPlayerState: media.AVPlayerState = 'idle';
  private musicPreparingTarget: string = '';
  private soundPlayer: media.AVPlayer | null = null;
  private soundRawFd: media.AVFileDescriptor | null = null;
  private activeSoundName: string = '';
  private isPreparingSound: boolean = false;
  private soundPlayerState: media.AVPlayerState = 'idle';
  private soundPreparingTarget: string = '';
  private studyRoomPreferences: preferences.Preferences | null = null;
  private readonly preferencesName: string = 'study_room_preferences';

  async aboutToAppear() {
    await this.loadData();
    this.applyCurrentModeDuration();
    this.startClock();
    this.initMusicPlayer();
    this.initSoundPlayer();
  }

  async aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
    if (this.clockId !== -1) {
      clearInterval(this.clockId);
    }
    await this.releaseMusicPlayer();
    await this.releaseSoundPlayer();
  }

  getCurrentScene(): SceneData {
    return this.scenes[this.currentSceneIndex];
  }

  getSceneBackground(): Resource {
    switch (this.getCurrentScene().imageName) {
      case 'forest2.jpg':
        return $r('app.media.forest2');
      case 'sea1.jpg':
        return $r('app.media.sea1');
      case 'night_city2.jpg':
        return $r('app.media.night_city2');
      default:
        return $r('app.media.background');
    }
  }

  // ----- 日期工具 -----
  getDateKey(date: Date): string {
    const year = date.getFullYear();
    const month = `${date.getMonth() + 1}`.padStart(2, '0');
    const day = `${date.getDate()}`.padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  getTodayKey(): string {
    return this.getDateKey(new Date());
  }

  // ----- 音频控制（与之前完全一致） -----
  async setMusicEnabled(enable: boolean) {
    if (this.musicEnabled === enable) return;
    this.musicEnabled = enable;
    if (enable) {
      this.activeMusicName = '';
      await this.updateSceneMusic();
      promptAction.showToast({
        message: '已开启沉浸音乐',
        duration: 1200
      });
    } else {
      this.activeMusicName = '';
      await this.stopMusicPlayback();
      promptAction.showToast({
        message: '已关闭沉浸音乐',
        duration: 1200
      });
    }
  }

  async setSoundEnabled(enable: boolean) {
    if (this.soundEnabled === enable) return;
    this.soundEnabled = enable;
    if (enable) {
      this.activeSoundName = '';
      await this.updateSceneSound();
      promptAction.showToast({
        message: '已开启环境音效',
        duration: 1200
      });
    } else {
      this.activeSoundName = '';
      await this.stopSoundPlayback();
      promptAction.showToast({
        message: '已关闭环境音效',
        duration: 1200
      });
    }
  }

  // ----- 音频引擎（与之前完全一致） -----
  async initMusicPlayer() {
    try {
      this.musicPlayer = await media.createAVPlayer();
      this.musicPlayer.loop = true;
      this.musicPlayer.on('stateChange', (state: media.AVPlayerState) => {
        this.musicPlayerState = state;
        console.info(`[StudyRoomMusic] stateChange -> ${state}`);
      });
      this.musicPlayer.on('error', (error) => {
        console.error(`[StudyRoomMusic] player error: ${JSON.stringify(error)}`);
      });
      await this.updateSceneMusic();
    } catch (error) {
      console.error(`[StudyRoomMusic] init failed: ${JSON.stringify(error)}`);
    }
  }

  async releaseMusicPlayer() {
    await this.closeMusicRawFd();
    if (this.musicPlayer !== null) {
      try {
        await this.musicPlayer.release();
      } catch (error) {
        console.error(`[StudyRoomMusic] release failed: ${JSON.stringify(error)}`);
      }
      this.musicPlayer = null;
      this.musicPlayerState = 'released';
    }
  }

  async closeMusicRawFd() {
    if (this.musicRawFd === null) {
      return;
    }
    try {
      getContext(this).resourceManager.closeRawFileDescriptor(this.activeMusicName);
    } catch (error) {
      console.error(`[StudyRoomMusic] close raw fd skipped: ${JSON.stringify(error)}`);
    }
    this.musicRawFd = null;
  }

  async waitForMusicState(expectedState: media.AVPlayerState, timeoutMs: number = 2500) {
    const startTime = Date.now();
    while (this.musicPlayerState !== expectedState) {
      if (Date.now() - startTime > timeoutMs) {
        throw new Error(`wait state timeout, expected=${expectedState}, current=${this.musicPlayerState}`);
      }
      await new Promise<void>((resolve) => {
        setTimeout(() => resolve(), 80);
      });
    }
  }

  async stopMusicPlayback() {
    if (this.musicPlayer === null) {
      return;
    }

    if (this.musicPlayerState === 'playing' || this.musicPlayerState === 'paused' || this.musicPlayerState === 'completed') {
      try {
        await this.musicPlayer.stop();
      } catch (error) {
        console.error(`[StudyRoomMusic] stop skipped: ${JSON.stringify(error)}`);
      }
    }

    if (this.musicPlayerState === 'initialized' ||
      this.musicPlayerState === 'prepared' ||
      this.musicPlayerState === 'playing' ||
      this.musicPlayerState === 'paused' ||
      this.musicPlayerState === 'completed' ||
      this.musicPlayerState === 'stopped' ||
      this.musicPlayerState === 'error') {
      try {
        await this.musicPlayer.reset();
      } catch (error) {
        console.error(`[StudyRoomMusic] reset skipped: ${JSON.stringify(error)}`);
      }
    }
  }

  async initSoundPlayer() {
    try {
      this.soundPlayer = await media.createAVPlayer();
      this.soundPlayer.loop = true;
      this.soundPlayer.on('stateChange', (state: media.AVPlayerState) => {
        this.soundPlayerState = state;
        console.info(`[StudyRoomSound] stateChange -> ${state}`);
      });
      this.soundPlayer.on('error', (error) => {
        console.error(`[StudyRoomSound] player error: ${JSON.stringify(error)}`);
      });
      await this.updateSceneSound();
    } catch (error) {
      console.error(`[StudyRoomSound] init failed: ${JSON.stringify(error)}`);
    }
  }

  async releaseSoundPlayer() {
    await this.closeSoundRawFd();
    if (this.soundPlayer !== null) {
      try {
        await this.soundPlayer.release();
      } catch (error) {
        console.error(`[StudyRoomSound] release failed: ${JSON.stringify(error)}`);
      }
      this.soundPlayer = null;
      this.soundPlayerState = 'released';
    }
  }

  async closeSoundRawFd() {
    if (this.soundRawFd === null) {
      return;
    }
    try {
      getContext(this).resourceManager.closeRawFileDescriptor(this.activeSoundName);
    } catch (error) {
      console.error(`[StudyRoomSound] close raw fd skipped: ${JSON.stringify(error)}`);
    }
    this.soundRawFd = null;
  }

  async waitForSoundState(expectedState: media.AVPlayerState, timeoutMs: number = 2500) {
    const startTime = Date.now();
    while (this.soundPlayerState !== expectedState) {
      if (Date.now() - startTime > timeoutMs) {
        throw new Error(`wait state timeout, expected=${expectedState}, current=${this.soundPlayerState}`);
      }
      await new Promise<void>((resolve) => {
        setTimeout(() => resolve(), 80);
      });
    }
  }

  async stopSoundPlayback() {
    if (this.soundPlayer === null) {
      return;
    }

    if (this.soundPlayerState === 'playing' || this.soundPlayerState === 'paused' || this.soundPlayerState === 'completed') {
      try {
        await this.soundPlayer.stop();
      } catch (error) {
        console.error(`[StudyRoomSound] stop skipped: ${JSON.stringify(error)}`);
      }
    }

    if (this.soundPlayerState === 'initialized' ||
      this.soundPlayerState === 'prepared' ||
      this.soundPlayerState === 'playing' ||
      this.soundPlayerState === 'paused' ||
      this.soundPlayerState === 'completed' ||
      this.soundPlayerState === 'stopped' ||
      this.soundPlayerState === 'error') {
      try {
        await this.soundPlayer.reset();
      } catch (error) {
        console.error(`[StudyRoomSound] reset skipped: ${JSON.stringify(error)}`);
      }
    }
  }

  async updateSceneSound() {
    if (!this.soundEnabled || this.soundPlayer === null || this.isPreparingSound) {
      return;
    }

    const targetSound = this.getCurrentScene().soundName;
    if (this.activeSoundName === targetSound) {
      return;
    }

    this.isPreparingSound = true;
    this.soundPreparingTarget = targetSound;
    try {
      console.info(`[StudyRoomSound] update start target=${targetSound} currentState=${this.soundPlayerState}`);
      await this.stopSoundPlayback();
      await this.closeSoundRawFd();
      const rawFd = await getContext(this).resourceManager.getRawFd(targetSound);
      console.info(`[StudyRoomSound] raw fd loaded target=${targetSound} fd=${rawFd.fd} offset=${rawFd.offset} length=${rawFd.length}`);
      this.soundRawFd = {
        fd: rawFd.fd,
        offset: rawFd.offset,
        length: rawFd.length
      };
      this.soundPlayer.fdSrc = this.soundRawFd;
      console.info(`[StudyRoomSound] fdSrc assigned target=${targetSound} state=${this.soundPlayerState}`);
      await this.waitForSoundState('initialized');
      console.info(`[StudyRoomSound] preparing target=${targetSound}`);
      await this.soundPlayer.prepare();
      await this.waitForSoundState('prepared');
      console.info(`[StudyRoomSound] playing target=${targetSound}`);
      await this.soundPlayer.play();
      await this.waitForSoundState('playing');
      this.activeSoundName = targetSound;
      console.info(`[StudyRoomSound] update success target=${targetSound}`);
    } catch (error) {
      console.error(`[StudyRoomSound] update failed target=${targetSound} state=${this.soundPlayerState} error=${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '环境音加载失败，请检查音频资源',
        duration: 1200
      });
    } finally {
      this.isPreparingSound = false;
      this.soundPreparingTarget = '';
    }
  }

  async updateSceneMusic() {
    if (!this.musicEnabled || this.musicPlayer === null || this.isPreparingMusic) {
      return;
    }

    const targetMusic = this.getCurrentScene().musicName;
    if (this.activeMusicName === targetMusic) {
      return;
    }

    this.isPreparingMusic = true;
    this.musicPreparingTarget = targetMusic;
    try {
      console.info(`[StudyRoomMusic] update start target=${targetMusic} currentState=${this.musicPlayerState}`);
      await this.stopMusicPlayback();
      await this.closeMusicRawFd();
      const rawFd = await getContext(this).resourceManager.getRawFd(targetMusic);
      console.info(`[StudyRoomMusic] raw fd loaded target=${targetMusic} fd=${rawFd.fd} offset=${rawFd.offset} length=${rawFd.length}`);
      this.musicRawFd = {
        fd: rawFd.fd,
        offset: rawFd.offset,
        length: rawFd.length
      };
      this.musicPlayer.fdSrc = this.musicRawFd;
      console.info(`[StudyRoomMusic] fdSrc assigned target=${targetMusic} state=${this.musicPlayerState}`);
      await this.waitForMusicState('initialized');
      console.info(`[StudyRoomMusic] preparing target=${targetMusic}`);
      await this.musicPlayer.prepare();
      await this.waitForMusicState('prepared');
      console.info(`[StudyRoomMusic] playing target=${targetMusic}`);
      await this.musicPlayer.play();
      await this.waitForMusicState('playing');
      this.activeMusicName = targetMusic;
      console.info(`[StudyRoomMusic] update success target=${targetMusic}`);
    } catch (error) {
      console.error(`[StudyRoomMusic] update failed target=${targetMusic} state=${this.musicPlayerState} error=${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '音乐加载失败，请检查音频资源',
        duration: 1200
      });
    } finally {
      this.isPreparingMusic = false;
      this.musicPreparingTarget = '';
    }
  }

  // ----- 计时器逻辑 -----
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

  async ensurePreferences() {
    if (this.studyRoomPreferences !== null) {
      return this.studyRoomPreferences;
    }
    this.studyRoomPreferences = await preferences.getPreferences(getContext(this), this.preferencesName);
    return this.studyRoomPreferences;
  }

  async loadData() {
    try {
      const store = await this.ensurePreferences();
      const todayKey = this.getTodayKey();
      const savedDate = (await store.get('statsDate', '')) as string;

      if (savedDate === todayKey) {
        this.tomatoCount = Number((await store.get('tomatoCount', 0)) as number);
        this.completedFocusSessions = Number((await store.get('completedFocusSessions', 0)) as number);
        this.totalFocusSeconds = Number((await store.get('totalFocusSeconds', 0)) as number);
      } else {
        this.tomatoCount = 0;
        this.completedFocusSessions = 0;
        this.totalFocusSeconds = 0;
        await store.put('statsDate', todayKey);
        await store.put('tomatoCount', 0);
        await store.put('completedFocusSessions', 0);
        await store.put('totalFocusSeconds', 0);
      }

      // 读取陪伴系统数据（不随日期重置）
      this.continuousDays = Number((await store.get('continuousDays', 0)) as number);
      this.totalTomatoCount = Number((await store.get('totalTomatoCount', 0)) as number);
      this.lastActiveDate = (await store.get('lastActiveDate', '')) as string;

      // 读取待办
      const savedTodos = (await store.get('todoList', '')) as string;
      if (savedTodos !== undefined && savedTodos !== '') {
        const parsed: TodoItem[] = JSON.parse(savedTodos);
        if (Array.isArray(parsed)) {
          const normalizedTodoList: TodoItem[] = [];
          parsed.forEach((item: TodoItem, index: number) => {
            const normalizedItem: TodoItem = {
              id: item.id ?? Date.now() + index,
              text: item.text,
              completed: item.completed,
              pinned: item.pinned ?? false
            };
            normalizedTodoList.push(normalizedItem);
          });
          this.todoList = normalizedTodoList;
        } else {
          await this.initDefaultTodos();
        }
      } else {
        await this.initDefaultTodos();
      }

      await store.flush();
    } catch (e) {
      await this.initDefaultTodos();
    }
  }

  async initDefaultTodos() {
    this.todoList = [
      { id: 1, text: '阅读', completed: false, pinned: true },
      { id: 2, text: '笔记', completed: false, pinned: false },
      { id: 3, text: '复习', completed: false, pinned: false }
    ];
    await this.saveStudyData();
  }

  async saveStudyData() {
    try {
      const store = await this.ensurePreferences();
      await store.put('statsDate', this.getTodayKey());
      await store.put('todoList', JSON.stringify(this.todoList));
      await store.put('tomatoCount', this.tomatoCount);
      await store.put('completedFocusSessions', this.completedFocusSessions);
      await store.put('totalFocusSeconds', this.totalFocusSeconds);
      // 陪伴系统数据
      await store.put('continuousDays', this.continuousDays);
      await store.put('totalTomatoCount', this.totalTomatoCount);
      await store.put('lastActiveDate', this.lastActiveDate);
      await store.flush();
    } catch (error) {
      console.error(`save study data failed: ${JSON.stringify(error)}`);
    }
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
      return '专注';
    }
    if (mode === 'shortBreak') {
      return '短休息';
    }
    return '长休息';
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
  }

  completeCurrentSession() {
    this.stopTimer();
    if (this.currentMode === 'focus') {
      this.tomatoCount = this.tomatoCount + 1;
      this.completedFocusSessions = this.completedFocusSessions + 1;
      // ---- 陪伴系统数据更新 ----
      this.totalTomatoCount = this.totalTomatoCount + 1;
      const today = this.getTodayKey();
      if (this.lastActiveDate !== today) {
        // 如果上次不是今天，更新连续天数
        if (this.lastActiveDate === '') {
          // 第一次使用
          this.continuousDays = 1;
        } else {
          const yesterday = new Date();
          yesterday.setDate(yesterday.getDate() - 1);
          const yesterdayKey = this.getDateKey(yesterday);
          if (this.lastActiveDate === yesterdayKey) {
            this.continuousDays = this.continuousDays + 1;
          } else {
            this.continuousDays = 1; // 中断重置
          }
        }
        this.lastActiveDate = today;
      }
      void this.saveStudyData();

      const nextMode: TimerMode = this.completedFocusSessions % 4 === 0 ? 'longBreak' : 'shortBreak';
      this.switchMode(nextMode, true);
      promptAction.showToast({
        message: `专注结束，进入${this.getModeLabel(nextMode)}`,
        duration: 2000
      });
      return;
    }

    this.switchMode('focus', true);
    promptAction.showToast({
      message: '休息结束，开始专注',
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
        if (this.currentMode === 'focus') {
          this.totalFocusSeconds = this.totalFocusSeconds + 1;
        }
        this.updateTimerDisplay();
        if (this.totalSeconds === 0) {
          this.completeCurrentSession();
        }
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

  randomScene() {
    if (this.scenes.length <= 1) {
      return;
    }
    let nextIndex = this.currentSceneIndex;
    while (nextIndex === this.currentSceneIndex) {
      nextIndex = Math.floor(Math.random() * this.scenes.length);
    }
    this.switchScene(nextIndex);
  }

  async switchScene(index: number) {
    if (index < 0 || index >= this.scenes.length || index === this.currentSceneIndex) {
      return;
    }
    animateTo({ duration: 260, curve: Curve.EaseInOut }, () => {
      this.backgroundOverlayOpacity = 0.18;
      this.sceneInfoScale = 0.98;
      this.currentSceneIndex = index;
    });
    animateTo({ duration: 360, delay: 60, curve: Curve.EaseOut }, () => {
      this.backgroundOverlayOpacity = 0.30;
      this.sceneInfoScale = 1;
    });
    this.activeMusicName = '';
    this.activeSoundName = '';
    await this.updateSceneMusic();
    await this.updateSceneSound();
  }

  toggleTodo(index: number) {
    const nextTodoList: TodoItem[] = [];
    this.todoList.forEach((item: TodoItem, itemIndex: number) => {
      const nextItem: TodoItem = {
        id: item.id,
        text: item.text,
        completed: itemIndex === index ? !item.completed : item.completed,
        pinned: item.pinned
      };
      nextTodoList.push(nextItem);
    });
    this.todoList = nextTodoList;
    void this.saveStudyData();
  }

  toggleCompletedSection() {
    this.showCompletedTodos = !this.showCompletedTodos;
  }

  pinTodo(index: number) {
    const nextTodoList: TodoItem[] = [];
    this.todoList.forEach((item: TodoItem, itemIndex: number) => {
      const nextItem: TodoItem = {
        id: item.id,
        text: item.text,
        completed: item.completed,
        pinned: itemIndex === index ? !item.pinned : item.pinned
      };
      nextTodoList.push(nextItem);
    });
    this.todoList = nextTodoList;
    void this.saveStudyData();
  }

  addTodo() {
    const trimmedText = this.newTodoText.trim();
    if (trimmedText === '') {
      return;
    }
    const nextTodoList: TodoItem[] = [];
    this.todoList.forEach((item: TodoItem) => {
      nextTodoList.push(item);
    });
    const newTodo: TodoItem = {
      id: Date.now(),
      text: trimmedText,
      completed: false,
      pinned: false
    };
    nextTodoList.push(newTodo);
    this.todoList = nextTodoList;
    this.newTodoText = '';
    void this.saveStudyData();
  }

  deleteTodo(index: number) {
    const nextTodoList: TodoItem[] = [];
    this.todoList.forEach((item: TodoItem, itemIndex: number) => {
      if (itemIndex !== index) {
        nextTodoList.push(item);
      }
    });
    this.todoList = nextTodoList;
    void this.saveStudyData();
  }

  build() {
    Stack() {
      // 背景图（模糊）
      Image(this.getSceneBackground())
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(6)

      // 渐变遮罩1
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [
            ['rgba(11,14,20,0.08)', 0],
            [this.getCurrentScene().bgColor, 0.55],
            ['#161A24', 1]
          ]
        })

      // 渐变遮罩2
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(`rgba(8,12,20,${this.backgroundOverlayOpacity})`)

      // 主内容
      Column() {
        Row()
          .height(24)
          .width('100%')

        Tabs({ barPosition: BarPosition.End }) {
          // ----- Tab 1: 学习 -----
          TabContent() {
            Scroll() {
              Column() {
                SceneSelector({
                  scenes: this.scenes,
                  currentSceneIndex: this.currentSceneIndex,
                  onSceneChange: (index: number) => {
                    this.switchScene(index);
                  },
                  onRandomScene: () => {
                    this.randomScene();
                  }
                })

                // 合并后的音乐/音效开关
                Row() {
                  Row() {
                    Text('音乐')
                      .fontSize(14)
                      .fontColor('#D5D9DE')
                    Toggle({ type: ToggleType.Switch, isOn: this.musicEnabled })
                      .onChange((isOn: boolean) => {
                        this.setMusicEnabled(isOn);
                      })
                    Text(this.getCurrentScene().musicLabel)
                      .fontSize(11)
                      .fontColor('#D5D9DE')
                      .maxLines(1)
                      .layoutWeight(1)
                  }
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor('rgba(255,255,255,0.08)')
                  .borderRadius(20)
                  .layoutWeight(1)

                  Divider()
                    .vertical(true)
                    .height(24)
                    .margin({ left: 6, right: 6 })
                    .color('rgba(255,255,255,0.12)')

                  Row() {
                    Text('音效')
                      .fontSize(14)
                      .fontColor('#D5D9DE')
                    Toggle({ type: ToggleType.Switch, isOn: this.soundEnabled })
                      .onChange((isOn: boolean) => {
                        this.setSoundEnabled(isOn);
                      })
                    Text(this.getCurrentScene().soundLabel)
                      .fontSize(11)
                      .fontColor('#D5D9DE')
                      .maxLines(1)
                      .layoutWeight(1)
                  }
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor('rgba(255,255,255,0.08)')
                  .borderRadius(20)
                  .layoutWeight(1)
                }
                .width('90%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .backgroundColor('rgba(17,20,29,0.30)')
                .borderRadius(24)
                .margin({ bottom: 12 })

                // 计时器
                TimerComponent({
                  timerDisplay: this.timerDisplay,
                  currentMode: this.currentMode,
                  isRunning: this.isRunning,
                  completedFocusSessions: this.completedFocusSessions,
                  totalFocusSeconds: this.totalFocusSeconds,
                  totalSeconds: this.totalSeconds,
                  totalDuration: this.currentSessionTotalSeconds,
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

                // 今日番茄数
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
              }
              .width('100%')
              .scale({ x: this.sceneInfoScale, y: this.sceneInfoScale })
              .alignItems(HorizontalAlign.Center)
            }
            .scrollBar(BarState.Auto)
            .edgeEffect(EdgeEffect.Spring)
            .backgroundColor('rgba(0,0,0,0)')
            .width('100%')
            .layoutWeight(1)
          }
          .tabBar('📚 学习')

          // ----- Tab 2: 待办 -----
          TabContent() {
            Scroll() {
              TodoComponent({
                todoList: this.todoList,
                newTodoText: this.newTodoText,
                showCompleted: this.showCompletedTodos,
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
                },
                onToggleCompletedSection: () => {
                  this.toggleCompletedSection();
                },
                onPin: (index: number) => {
                  this.pinTodo(index);
                }
              })
            }
            .scrollBar(BarState.Auto)
            .edgeEffect(EdgeEffect.Spring)
            .width('100%')
            .layoutWeight(1)
          }
          .tabBar('✅ 待办')

          // ----- Tab 3: 陪伴系统（新） -----
          TabContent() {
            CompanionComponent({
              continuousDays: this.continuousDays,
              totalTomatoCount: this.totalTomatoCount
            })
          }
          .tabBar('🤝 陪伴')
        }
        .width('100%')
        .layoutWeight(1)

        // 底部时间 & 名言
        Row() {
          Text(this.currentTime)
            .fontSize(13)
            .fontColor('#CCCCCC')
            .padding({ left: 14, right: 14, top: 5, bottom: 5 })
            .backgroundColor('rgba(0,0,0,0.3)')
            .borderRadius(22)

          Blank()

          Text(this.getCurrentScene().quote)
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