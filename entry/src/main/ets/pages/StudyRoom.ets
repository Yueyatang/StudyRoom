import promptAction from '@ohos.promptAction';
import media from '@ohos.multimedia.media';
import preferences from '@ohos.data.preferences';
import { SceneSelector } from '../components/SceneSelector';
import { TimerComponent } from '../components/TimerComponent';
import { TodoComponent } from '../components/TodoComponent';
import { CompanionComponent } from '../components/CompanionComponent';
import { AuthComponent } from '../components/AuthComponent';
import { ProfileComponent } from '../components/ProfileComponent';
import { StatsComponent } from '../components/StatsComponent';
import { ImmersionVideoComponent } from '../components/ImmersionVideoComponent';
import { AuthMode, DailyTomatoRecord, SceneData, TimerMode, TodoItem, UserProfile } from '../common/StudyRoomTypes';

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
      atmosphere: '浪声有节律，能帮助你把注意力拉回当下。',
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
  @State activeTodoId: number = -1;
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

  @State continuousDays: number = 0;
  @State totalTomatoCount: number = 0;
  @State lastActiveDate: string = '';
  @State statsVersion: number = 0;
  @State dailyTomatoRecords: DailyTomatoRecord[] = [];

  @State isLoggedIn: boolean = false;
  @State authMode: AuthMode = 'login';
  @State authAccount: string = '';
  @State authPassword: string = '';
  @State authNickname: string = '';
  @State authConfirmPassword: string = '';
  @State savedAccount: string = '';
  @State savedPassword: string = '';
  @State currentTabIndex: number = 0;
  @State profile: UserProfile = {
    nickname: '学习搭子',
    account: '',
    signature: '今天也要稳定专注。',
    targetTomatoes: 6
  };

  private timerId: number = -1;
  private clockId: number = -1;
  private musicPlayer: media.AVPlayer | null = null;
  private musicRawFd: media.AVFileDescriptor | null = null;
  private activeMusicName: string = '';
  private isPreparingMusic: boolean = false;
  private musicPlayerState: media.AVPlayerState = 'idle';
  private soundPlayer: media.AVPlayer | null = null;
  private soundRawFd: media.AVFileDescriptor | null = null;
  private activeSoundName: string = '';
  private isPreparingSound: boolean = false;
  private soundPlayerState: media.AVPlayerState = 'idle';
  private studyRoomPreferences: preferences.Preferences | null = null;
  private readonly preferencesName: string = 'study_room_preferences';
  private readonly enableMockData: boolean = true;

  async aboutToAppear() {
    await this.loadData();
    if (this.enableMockData) {
      this.applyMockData();
    }
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

  getDateKey(date: Date): string {
    const year = date.getFullYear();
    const month = `${date.getMonth() + 1}`.padStart(2, '0');
    const day = `${date.getDate()}`.padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  getTodayKey(): string {
    return this.getDateKey(new Date());
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

  getTotalFocusMinutes(): number {
    return Math.floor(this.totalFocusSeconds / 60);
  }

  refreshStatsView() {
    this.statsVersion = this.statsVersion + 1;
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

      this.continuousDays = Number((await store.get('continuousDays', 0)) as number);
      this.totalTomatoCount = Number((await store.get('totalTomatoCount', 0)) as number);
      this.lastActiveDate = (await store.get('lastActiveDate', '')) as string;
      this.dailyTomatoRecords = this.normalizeDailyTomatoRecords((await store.get('dailyTomatoRecords', '')) as string);
      this.syncTodayTomatoRecord();
      this.activeTodoId = Number((await store.get('activeTodoId', -1)) as number);
      this.isLoggedIn = Boolean((await store.get('isLoggedIn', false)) as boolean);
      this.savedAccount = (await store.get('savedAccount', '')) as string;
      this.savedPassword = (await store.get('savedPassword', '')) as string;
      this.profile = {
        nickname: (await store.get('profileNickname', '学习搭子')) as string,
        account: this.savedAccount,
        signature: (await store.get('profileSignature', '今天也要稳定专注。')) as string,
        targetTomatoes: Number((await store.get('profileTargetTomatoes', 6)) as number)
      };

      const savedTodos = (await store.get('todoList', '')) as string;
      if (savedTodos !== undefined && savedTodos !== '') {
        const parsed: TodoItem[] = JSON.parse(savedTodos);
        if (Array.isArray(parsed)) {
          const normalizedTodoList: TodoItem[] = [];
          parsed.forEach((item: TodoItem, index: number) => {
            normalizedTodoList.push({
              id: item.id ?? Date.now() + index,
              text: item.text,
              completed: item.completed,
              pinned: item.pinned ?? false,
              estimatedTomatoes: Math.max(1, Number(item.estimatedTomatoes ?? 1)),
              doneTomatoes: Math.max(0, Number(item.doneTomatoes ?? 0))
            });
          });
          this.todoList = normalizedTodoList;
          if (this.getActiveTodoIndex() === -1) {
            this.activeTodoId = -1;
          }
        } else {
          await this.initDefaultTodos();
        }
      } else {
        await this.initDefaultTodos();
      }

      await store.flush();
    } catch (error) {
      await this.initDefaultTodos();
    }
  }

  async saveStudyData() {
    try {
      const store = await this.ensurePreferences();
      await store.put('statsDate', this.getTodayKey());
      await store.put('todoList', JSON.stringify(this.todoList));
      await store.put('tomatoCount', this.tomatoCount);
      await store.put('completedFocusSessions', this.completedFocusSessions);
      await store.put('totalFocusSeconds', this.totalFocusSeconds);
      await store.put('continuousDays', this.continuousDays);
      await store.put('totalTomatoCount', this.totalTomatoCount);
      await store.put('lastActiveDate', this.lastActiveDate);
      await store.put('dailyTomatoRecords', JSON.stringify(this.dailyTomatoRecords));
      await store.put('activeTodoId', this.activeTodoId);
      await store.put('isLoggedIn', this.isLoggedIn);
      await store.put('savedAccount', this.savedAccount);
      await store.put('savedPassword', this.savedPassword);
      await store.put('profileNickname', this.profile.nickname);
      await store.put('profileSignature', this.profile.signature);
      await store.put('profileTargetTomatoes', this.profile.targetTomatoes);
      await store.flush();
    } catch (error) {
      console.error(`save study data failed: ${JSON.stringify(error)}`);
    }
  }

  async initDefaultTodos() {
    this.todoList = [
      { id: 1, text: '阅读', completed: false, pinned: true, estimatedTomatoes: 2, doneTomatoes: 0 },
      { id: 2, text: '笔记整理', completed: false, pinned: false, estimatedTomatoes: 1, doneTomatoes: 0 },
      { id: 3, text: '复习巩固', completed: false, pinned: false, estimatedTomatoes: 2, doneTomatoes: 0 }
    ];
    await this.saveStudyData();
  }

  getActiveTodoIndex(): number {
    for (let index = 0; index < this.todoList.length; index++) {
      if (this.todoList[index].id === this.activeTodoId && !this.todoList[index].completed) {
        return index;
      }
    }
    return -1;
  }

  getActiveTodoText(): string {
    const activeIndex = this.getActiveTodoIndex();
    if (activeIndex === -1) {
      return '';
    }
    return this.todoList[activeIndex].text;
  }

  getActiveTodoProgressText(): string {
    const activeIndex = this.getActiveTodoIndex();
    if (activeIndex === -1) {
      return '';
    }
    return `${this.todoList[activeIndex].doneTomatoes}/${this.todoList[activeIndex].estimatedTomatoes} 番茄`;
  }

  applyMockData() {
    const todayKey = this.getTodayKey();
    this.currentSceneIndex = 1;
    this.currentTabIndex = 0;
    this.isLoggedIn = true;
    this.savedAccount = '8209230113';
    this.savedPassword = '123456';
    this.profile = {
      nickname: '卿晨',
      account: this.savedAccount,
      signature: '用番茄钟把每天的学习沉淀下来。',
      targetTomatoes: 6
    };

    this.tomatoCount = 4;
    this.completedFocusSessions = 4;
    this.totalFocusSeconds = 95 * 60;
    this.totalTomatoCount = 52;
    this.continuousDays = 12;
    this.lastActiveDate = todayKey;
    this.showCompletedTodos = true;

    this.todoList = [
      {
        id: 1001,
        text: '完善鸿蒙课程项目报告',
        completed: false,
        pinned: true,
        estimatedTomatoes: 4,
        doneTomatoes: 2
      },
      {
        id: 1002,
        text: '整理 StudyRoom 演示截图',
        completed: false,
        pinned: false,
        estimatedTomatoes: 3,
        doneTomatoes: 1
      },
      {
        id: 1003,
        text: '复习 ArkTS 状态管理',
        completed: false,
        pinned: false,
        estimatedTomatoes: 2,
        doneTomatoes: 0
      },
      {
        id: 1004,
        text: '完成 Lottie 陪伴角色说明',
        completed: true,
        pinned: false,
        estimatedTomatoes: 2,
        doneTomatoes: 2
      },
      {
        id: 1005,
        text: '测试音乐与环境音切换',
        completed: true,
        pinned: false,
        estimatedTomatoes: 1,
        doneTomatoes: 1
      }
    ];
    this.activeTodoId = 1001;
    this.dailyTomatoRecords = this.buildMockDailyTomatoRecords();
    this.refreshStatsView();
  }

  buildMockDailyTomatoRecords(): DailyTomatoRecord[] {
    const mockCounts: number[] = [
      0, 1, 2, 4, 0, 3, 5, 1, 0, 2,
      3, 6, 0, 1, 4, 2, 0, 5, 3, 1,
      0, 0, 2, 4, 6, 1, 3, 0, 2, 5,
      4, 0, 1, 2, 6, 3, 0, 4, 5, 2,
      1, 0, 3, 6, 4, 2, 0, 1, 5, 3,
      2, 4, 0, 6, 1, 3, 5, 0, 2, 4,
      6, 3, 1, 0, 5, 2, 4, 3, 1, 4
    ];
    const records: DailyTomatoRecord[] = [];
    for (let offset = 69; offset >= 0; offset--) {
      const date = new Date();
      date.setDate(date.getDate() - offset);
      const countIndex = 69 - offset;
      records.push({
        date: this.getDateKey(date),
        count: mockCounts[countIndex]
      });
    }
    return records;
  }

  normalizeDailyTomatoRecords(rawRecords: string): DailyTomatoRecord[] {
    if (rawRecords === '') {
      return [];
    }
    try {
      const parsed = JSON.parse(rawRecords) as DailyTomatoRecord[];
      if (!Array.isArray(parsed)) {
        return [];
      }
      const normalizedRecords: DailyTomatoRecord[] = [];
      parsed.forEach((item: DailyTomatoRecord) => {
        if (item.date !== undefined && item.date !== '') {
          normalizedRecords.push({
            date: item.date,
            count: Math.max(0, Number(item.count ?? 0))
          });
        }
      });
      return normalizedRecords;
    } catch (error) {
      return [];
    }
  }

  syncTodayTomatoRecord() {
    const todayKey = this.getTodayKey();
    let hasToday = false;
    this.dailyTomatoRecords = this.dailyTomatoRecords.map((item: DailyTomatoRecord) => {
      if (item.date === todayKey) {
        hasToday = true;
        return {
          date: item.date,
          count: this.tomatoCount
        };
      }
      return item;
    });
    if (!hasToday) {
      this.dailyTomatoRecords.push({
        date: todayKey,
        count: this.tomatoCount
      });
    }
    this.dailyTomatoRecords = this.dailyTomatoRecords.slice(-120);
  }

  getRecentTomatoRecords(): DailyTomatoRecord[] {
    const recentRecords: DailyTomatoRecord[] = [];
    for (let offset = 69; offset >= 0; offset--) {
      const date = new Date();
      date.setDate(date.getDate() - offset);
      const dateKey = this.getDateKey(date);
      let count = 0;
      this.dailyTomatoRecords.forEach((item: DailyTomatoRecord) => {
        if (item.date === dateKey) {
          count = item.count;
        }
      });
      recentRecords.push({
        date: dateKey,
        count: count
      });
    }
    return recentRecords;
  }

  recordActiveTodoTomato() {
    const activeIndex = this.getActiveTodoIndex();
    if (activeIndex === -1) {
      return;
    }
    const nextTodoList: TodoItem[] = [];
    let completedTaskName = '';
    this.todoList.forEach((item: TodoItem, index: number) => {
      if (index === activeIndex) {
        const nextDoneTomatoes = item.doneTomatoes + 1;
        const nextCompleted = nextDoneTomatoes >= item.estimatedTomatoes;
        if (nextCompleted) {
          completedTaskName = item.text;
          this.activeTodoId = -1;
        }
        nextTodoList.push({
          id: item.id,
          text: item.text,
          completed: nextCompleted,
          pinned: item.pinned,
          estimatedTomatoes: item.estimatedTomatoes,
          doneTomatoes: nextDoneTomatoes
        });
        return;
      }
      nextTodoList.push(item);
    });
    this.todoList = nextTodoList;
    if (completedTaskName !== '') {
      promptAction.showToast({ message: `任务「${completedTaskName}」已完成`, duration: 1600 });
    }
  }

  async setMusicEnabled(enable: boolean) {
    if (this.musicEnabled === enable) {
      return;
    }
    this.musicEnabled = enable;
    if (enable) {
      this.activeMusicName = '';
      await this.updateSceneMusic();
      promptAction.showToast({ message: '已开启沉浸音乐', duration: 1200 });
    } else {
      this.activeMusicName = '';
      await this.stopMusicPlayback();
      promptAction.showToast({ message: '已关闭沉浸音乐', duration: 1200 });
    }
  }

  async setSoundEnabled(enable: boolean) {
    if (this.soundEnabled === enable) {
      return;
    }
    this.soundEnabled = enable;
    if (enable) {
      this.activeSoundName = '';
      await this.updateSceneSound();
      promptAction.showToast({ message: '已开启环境音效', duration: 1200 });
    } else {
      this.activeSoundName = '';
      await this.stopSoundPlayback();
      promptAction.showToast({ message: '已关闭环境音效', duration: 1200 });
    }
  }

  async initMusicPlayer() {
    try {
      this.musicPlayer = await media.createAVPlayer();
      this.musicPlayer.loop = true;
      this.musicPlayer.on('stateChange', (state: media.AVPlayerState) => {
        this.musicPlayerState = state;
      });
      this.musicPlayer.on('error', (error) => {
        console.error(`[StudyRoomMusic] player error: ${JSON.stringify(error)}`);
      });
      await this.updateSceneMusic();
    } catch (error) {
      console.error(`[StudyRoomMusic] init failed: ${JSON.stringify(error)}`);
    }
  }

  async initSoundPlayer() {
    try {
      this.soundPlayer = await media.createAVPlayer();
      this.soundPlayer.loop = true;
      this.soundPlayer.on('stateChange', (state: media.AVPlayerState) => {
        this.soundPlayerState = state;
      });
      this.soundPlayer.on('error', (error) => {
        console.error(`[StudyRoomSound] player error: ${JSON.stringify(error)}`);
      });
      await this.updateSceneSound();
    } catch (error) {
      console.error(`[StudyRoomSound] init failed: ${JSON.stringify(error)}`);
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

  async waitForMusicState(expectedState: media.AVPlayerState, timeoutMs: number = 2500) {
    const startTime = Date.now();
    while (this.musicPlayerState !== expectedState) {
      if (Date.now() - startTime > timeoutMs) {
        throw new Error(`wait music state timeout: expected=${expectedState}, current=${this.musicPlayerState}`);
      }
      await new Promise<void>((resolve) => {
        setTimeout(() => resolve(), 80);
      });
    }
  }

  async waitForSoundState(expectedState: media.AVPlayerState, timeoutMs: number = 2500) {
    const startTime = Date.now();
    while (this.soundPlayerState !== expectedState) {
      if (Date.now() - startTime > timeoutMs) {
        throw new Error(`wait sound state timeout: expected=${expectedState}, current=${this.soundPlayerState}`);
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
    if (this.musicPlayerState !== 'idle' && this.musicPlayerState !== 'released') {
      try {
        await this.musicPlayer.reset();
      } catch (error) {
        console.error(`[StudyRoomMusic] reset skipped: ${JSON.stringify(error)}`);
      }
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
    if (this.soundPlayerState !== 'idle' && this.soundPlayerState !== 'released') {
      try {
        await this.soundPlayer.reset();
      } catch (error) {
        console.error(`[StudyRoomSound] reset skipped: ${JSON.stringify(error)}`);
      }
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
    try {
      await this.stopMusicPlayback();
      await this.closeMusicRawFd();
      const rawFd = await getContext(this).resourceManager.getRawFd(targetMusic);
      this.musicRawFd = {
        fd: rawFd.fd,
        offset: rawFd.offset,
        length: rawFd.length
      };
      this.musicPlayer.fdSrc = this.musicRawFd;
      await this.waitForMusicState('initialized');
      await this.musicPlayer.prepare();
      await this.waitForMusicState('prepared');
      await this.musicPlayer.play();
      await this.waitForMusicState('playing');
      this.activeMusicName = targetMusic;
    } catch (error) {
      console.error(`[StudyRoomMusic] update failed: ${JSON.stringify(error)}`);
      promptAction.showToast({ message: '音乐加载失败，请检查资源', duration: 1200 });
    } finally {
      this.isPreparingMusic = false;
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
    try {
      await this.stopSoundPlayback();
      await this.closeSoundRawFd();
      const rawFd = await getContext(this).resourceManager.getRawFd(targetSound);
      this.soundRawFd = {
        fd: rawFd.fd,
        offset: rawFd.offset,
        length: rawFd.length
      };
      this.soundPlayer.fdSrc = this.soundRawFd;
      await this.waitForSoundState('initialized');
      await this.soundPlayer.prepare();
      await this.waitForSoundState('prepared');
      await this.soundPlayer.play();
      await this.waitForSoundState('playing');
      this.activeSoundName = targetSound;
    } catch (error) {
      console.error(`[StudyRoomSound] update failed: ${JSON.stringify(error)}`);
      promptAction.showToast({ message: '环境音加载失败，请检查资源', duration: 1200 });
    } finally {
      this.isPreparingSound = false;
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

  getDurationForMode(mode: TimerMode): number {
    if (mode === 'focus') {
      return this.focusDuration;
    }
    if (mode === 'shortBreak') {
      return this.shortBreakDuration;
    }
    return this.longBreakDuration;
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

  showSessionReminder(title: string, message: string) {
    promptAction.showDialog({
      title: title,
      message: message,
      buttons: [
        {
          text: '知道了',
          color: '#FFD878'
        }
      ]
    }).catch((error: Error) => {
      console.error(`[StudyRoom] show session reminder failed: ${JSON.stringify(error)}`);
    });
  }

  completeCurrentSession() {
    this.stopTimer();
    if (this.currentMode === 'focus') {
      this.tomatoCount = this.tomatoCount + 1;
      this.completedFocusSessions = this.completedFocusSessions + 1;
      this.totalTomatoCount = this.totalTomatoCount + 1;
      this.syncTodayTomatoRecord();
      this.recordActiveTodoTomato();
      this.refreshStatsView();

      const today = this.getTodayKey();
      if (this.lastActiveDate !== today) {
        if (this.lastActiveDate === '') {
          this.continuousDays = 1;
        } else {
          const yesterday = new Date();
          yesterday.setDate(yesterday.getDate() - 1);
          const yesterdayKey = this.getDateKey(yesterday);
          this.continuousDays = this.lastActiveDate === yesterdayKey ? this.continuousDays + 1 : 1;
        }
        this.lastActiveDate = today;
      }
      void this.saveStudyData();

      const nextMode: TimerMode = this.completedFocusSessions % 4 === 0 ? 'longBreak' : 'shortBreak';
      this.switchMode(nextMode, true);
      this.showSessionReminder('专注完成', `本轮专注已结束，接下来进入${this.getModeLabel(nextMode)}。`);
      promptAction.showToast({
        message: `专注结束，进入${this.getModeLabel(nextMode)}`,
        duration: 2000
      });
      return;
    }

    this.switchMode('focus', true);
    this.showSessionReminder('休息结束', '休息时间结束，已为你切回下一轮专注。');
    promptAction.showToast({
      message: '休息结束，开始下一轮专注',
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
          if (this.totalFocusSeconds % 60 === 0) {
            this.refreshStatsView();
            void this.saveStudyData();
          }
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
      nextTodoList.push({
        id: item.id,
        text: item.text,
        completed: itemIndex === index ? !item.completed : item.completed,
        pinned: item.pinned,
        estimatedTomatoes: item.estimatedTomatoes,
        doneTomatoes: item.doneTomatoes
      });
    });
    if (this.todoList[index].id === this.activeTodoId) {
      this.activeTodoId = -1;
    }
    this.todoList = nextTodoList;
    void this.saveStudyData();
  }

  deleteTodo(index: number) {
    const nextTodoList: TodoItem[] = [];
    const deletedTodoId = this.todoList[index].id;
    this.todoList.forEach((item: TodoItem, itemIndex: number) => {
      if (itemIndex !== index) {
        nextTodoList.push(item);
      }
    });
    this.todoList = nextTodoList;
    if (deletedTodoId === this.activeTodoId) {
      this.activeTodoId = -1;
    }
    void this.saveStudyData();
  }

  pinTodo(index: number) {
    const nextTodoList: TodoItem[] = [];
    this.todoList.forEach((item: TodoItem, itemIndex: number) => {
      nextTodoList.push({
        id: item.id,
        text: item.text,
        completed: item.completed,
        pinned: itemIndex === index ? !item.pinned : item.pinned,
        estimatedTomatoes: item.estimatedTomatoes,
        doneTomatoes: item.doneTomatoes
      });
    });
    this.todoList = nextTodoList;
    void this.saveStudyData();
  }

  selectActiveTodo(index: number) {
    if (index < 0 || index >= this.todoList.length || this.todoList[index].completed) {
      return;
    }
    this.activeTodoId = this.todoList[index].id;
    this.currentTabIndex = 0;
    if (this.currentMode !== 'focus') {
      this.switchMode('focus');
    }
    this.startTimer();
    void this.saveStudyData();
    promptAction.showToast({ message: `开始专注：${this.todoList[index].text}`, duration: 1200 });
  }

  adjustTodoEstimate(index: number, delta: number) {
    if (index < 0 || index >= this.todoList.length) {
      return;
    }
    const nextTodoList: TodoItem[] = [];
    this.todoList.forEach((item: TodoItem, itemIndex: number) => {
      if (itemIndex === index) {
        const nextEstimate = Math.max(1, Math.min(12, item.estimatedTomatoes + delta));
        nextTodoList.push({
          id: item.id,
          text: item.text,
          completed: item.doneTomatoes >= nextEstimate,
          pinned: item.pinned,
          estimatedTomatoes: nextEstimate,
          doneTomatoes: item.doneTomatoes
        });
        return;
      }
      nextTodoList.push(item);
    });
    this.todoList = nextTodoList;
    if (this.getActiveTodoIndex() === -1) {
      this.activeTodoId = -1;
    }
    void this.saveStudyData();
  }

  toggleCompletedSection() {
    this.showCompletedTodos = !this.showCompletedTodos;
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
    nextTodoList.push({
      id: Date.now(),
      text: trimmedText,
      completed: false,
      pinned: false,
      estimatedTomatoes: 1,
      doneTomatoes: 0
    });
    this.todoList = nextTodoList;
    this.newTodoText = '';
    void this.saveStudyData();
  }

  switchAuthMode(mode: AuthMode) {
    this.authMode = mode;
    this.authPassword = '';
    this.authConfirmPassword = '';
  }

  async submitAuth() {
    const account = this.authAccount.trim();
    const password = this.authPassword.trim();
    const nickname = this.authNickname.trim();

    if (account === '' || password === '') {
      promptAction.showToast({ message: '请输入账号和密码', duration: 1200 });
      return;
    }

    if (this.authMode === 'register') {
      if (nickname === '') {
        promptAction.showToast({ message: '请输入昵称', duration: 1200 });
        return;
      }
      if (password !== this.authConfirmPassword.trim()) {
        promptAction.showToast({ message: '两次输入的密码不一致', duration: 1200 });
        return;
      }
      this.savedAccount = account;
      this.savedPassword = password;
      this.profile = {
        nickname: nickname,
        account: account,
        signature: this.profile.signature,
        targetTomatoes: this.profile.targetTomatoes > 0 ? this.profile.targetTomatoes : 6
      };
    } else {
      if (this.savedAccount !== '' && (account !== this.savedAccount || password !== this.savedPassword)) {
        promptAction.showToast({ message: '账号或密码错误', duration: 1200 });
        return;
      }
      if (this.savedAccount === '') {
        this.savedAccount = account;
        this.savedPassword = password;
        this.profile = {
          nickname: this.profile.nickname,
          account: account,
          signature: this.profile.signature,
          targetTomatoes: this.profile.targetTomatoes
        };
      }
    }

    this.isLoggedIn = true;
    this.profile = {
      nickname: this.profile.nickname === '' ? '学习搭子' : this.profile.nickname,
      account: this.savedAccount,
      signature: this.profile.signature,
      targetTomatoes: this.profile.targetTomatoes > 0 ? this.profile.targetTomatoes : 6
    };
    await this.saveStudyData();
    promptAction.showToast({
      message: this.authMode === 'login' ? '登录成功' : '注册成功',
      duration: 1200
    });
  }

  async logout() {
    this.isLoggedIn = false;
    this.authMode = 'login';
    this.authPassword = '';
    this.authConfirmPassword = '';
    await this.saveStudyData();
    promptAction.showToast({ message: '已退出登录', duration: 1200 });
  }

  async saveProfile() {
    this.profile = {
      nickname: this.profile.nickname.trim() === '' ? '学习搭子' : this.profile.nickname.trim(),
      account: this.profile.account,
      signature: this.profile.signature.trim() === '' ? '今天也要稳定专注。' : this.profile.signature.trim(),
      targetTomatoes: this.profile.targetTomatoes > 0 ? this.profile.targetTomatoes : 6
    };
    await this.saveStudyData();
    promptAction.showToast({ message: '个人资料已保存', duration: 1200 });
  }

  build() {
    Stack() {
      Image(this.getSceneBackground())
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(6)

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

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(`rgba(8,12,20,${this.backgroundOverlayOpacity})`)

      Column() {
        Row()
          .height(24)
          .width('100%')

        if (!this.isLoggedIn) {
          Column() {
            AuthComponent({
              authMode: this.authMode,
              account: this.authAccount,
              password: this.authPassword,
              nickname: this.authNickname,
              confirmPassword: this.authConfirmPassword,
              onModeChange: (mode: AuthMode) => {
                this.switchAuthMode(mode);
              },
              onAccountChange: (value: string) => {
                this.authAccount = value;
              },
              onPasswordChange: (value: string) => {
                this.authPassword = value;
              },
              onNicknameChange: (value: string) => {
                this.authNickname = value;
              },
              onConfirmPasswordChange: (value: string) => {
                this.authConfirmPassword = value;
              },
              onSubmit: () => {
                this.submitAuth();
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          Tabs({ barPosition: BarPosition.End, index: this.currentTabIndex }) {
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

                  this.buildActiveTodoCard()

                  StatsComponent({
                    todayTomatoCount: this.tomatoCount,
                    totalFocusMinutes: this.getTotalFocusMinutes(),
                    continuousDays: this.continuousDays,
                    totalTomatoCount: this.totalTomatoCount,
                    targetTomatoes: this.profile.targetTomatoes,
                    contributionDays: this.getRecentTomatoRecords(),
                    statsVersion: this.statsVersion
                  })

                  this.buildCompanionPreview()
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
            .tabBar(this.buildTabBarItem('学习', 0))

            TabContent() {
              Scroll() {
                TodoComponent({
                  todoList: this.todoList,
                  newTodoText: this.newTodoText,
                  showCompleted: this.showCompletedTodos,
                  activeTodoId: this.activeTodoId,
                  isFocusRunning: this.isRunning,
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
                  },
                  onSelectActive: (index: number) => {
                    this.selectActiveTodo(index);
                  },
                  onAdjustEstimate: (index: number, delta: number) => {
                    this.adjustTodoEstimate(index, delta);
                  }
                })
              }
              .scrollBar(BarState.Auto)
              .edgeEffect(EdgeEffect.Spring)
              .width('100%')
              .layoutWeight(1)
            }
            .tabBar(this.buildTabBarItem('清单', 1))

            TabContent() {
              CompanionComponent({
                continuousDays: this.continuousDays,
                totalTomatoCount: this.totalTomatoCount,
                todayTomatoCount: this.tomatoCount,
                statsVersion: this.statsVersion,
                animationName: 'cat_sleep.json'
              })
            }
            .tabBar(this.buildTabBarItem('陪伴', 2))

            TabContent() {
              ImmersionVideoComponent({
                isRunning: this.isRunning,
                timerDisplay: this.timerDisplay,
                currentSceneName: this.getCurrentScene().name,
                suggestion: this.getCurrentScene().suggestion,
                activeTaskText: this.getActiveTodoText(),
                activeTaskProgress: this.getActiveTodoProgressText()
              })
            }
            .tabBar(this.buildTabBarItem('沉浸', 3))

            TabContent() {
              ProfileComponent({
                profile: this.profile,
                continuousDays: this.continuousDays,
                totalTomatoCount: this.totalTomatoCount,
                todayTomatoCount: this.tomatoCount,
                totalFocusMinutes: this.getTotalFocusMinutes(),
                statsVersion: this.statsVersion,
                onNicknameChange: (value: string) => {
                  this.profile = {
                    nickname: value,
                    account: this.profile.account,
                    signature: this.profile.signature,
                    targetTomatoes: this.profile.targetTomatoes
                  };
                },
                onSignatureChange: (value: string) => {
                  this.profile = {
                    nickname: this.profile.nickname,
                    account: this.profile.account,
                    signature: value,
                    targetTomatoes: this.profile.targetTomatoes
                  };
                },
                onTargetChange: (value: string) => {
                  const target = Number(value);
                  this.profile = {
                    nickname: this.profile.nickname,
                    account: this.profile.account,
                    signature: this.profile.signature,
                    targetTomatoes: Number.isFinite(target) && target > 0 ? Math.floor(target) : 0
                  };
                },
                onSave: () => {
                  this.saveProfile();
                },
                onLogout: () => {
                  this.logout();
                }
              })
            }
            .tabBar(this.buildTabBarItem('我的', 4))
          }
          .width('100%')
          .layoutWeight(1)
          .barHeight(56)
          .barBackgroundColor('rgba(255,255,255,0.03)')
          .onChange((index: number) => {
            this.currentTabIndex = index;
          })
        }

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

  @Builder
  private buildTabBarItem(title: string, index: number) {
    Column({ space: 5 }) {
      Text(title)
        .fontSize(13)
        .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentTabIndex === index ? '#FFF2C2' : 'rgba(226,232,240,0.66)')
        .textAlign(TextAlign.Center)

      Row()
        .width(this.currentTabIndex === index ? 18 : 4)
        .height(3)
        .backgroundColor(this.currentTabIndex === index ? '#FFD878' : 'rgba(255,255,255,0)')
        .borderRadius(2)
    }
    .width(64)
    .height(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.currentTabIndex === index ? 'rgba(255,255,255,0.14)' : 'rgba(255,255,255,0)')
    .borderRadius(22)
  }

  @Builder
  private buildActiveTodoCard() {
    if (this.getActiveTodoIndex() !== -1) {
      Column({ space: 12 }) {
        Row() {
          Column({ space: 6 }) {
            Text('当前专注任务')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.56)')

            Text(this.todoList[this.getActiveTodoIndex()].text)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .maxLines(1)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Text(`${this.todoList[this.getActiveTodoIndex()].doneTomatoes}/${this.todoList[this.getActiveTodoIndex()].estimatedTomatoes} 番茄`)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFD878')
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor('rgba(255,216,120,0.14)')
            .borderRadius(16)
        }
        .width('100%')

        Row() {
          Column({ space: 4 }) {
            Text(this.currentMode === 'focus' ? '本轮倒计时' : this.getModeLabel(this.currentMode))
              .fontSize(11)
              .fontColor('rgba(255,255,255,0.52)')

            Text(this.timerDisplay)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontFamily('monospace')
              .fontColor('#FFFFFF')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          if (this.isRunning) {
            Text('进行中')
              .fontSize(12)
              .fontColor('#9EE2FF')
              .padding({ left: 12, right: 12, top: 7, bottom: 7 })
              .backgroundColor('rgba(158,226,255,0.14)')
              .borderRadius(16)
          } else {
            Button('开始')
              .fontSize(12)
              .fontColor('#1A2432')
              .height(32)
              .padding({ left: 16, right: 16 })
              .backgroundColor('#FFD878')
              .borderRadius(16)
              .onClick(() => {
                this.startTimer();
              })
          }
        }
        .width('100%')
      }
      .width('90%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor('rgba(22,28,38,0.62)')
      .borderRadius(24)
      .margin({ bottom: 12 })
    } else {
      Row() {
        Column({ space: 6 }) {
          Text('未选择专注任务')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text('完成番茄后可自动累计到任务进度')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.56)')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button('去选择')
          .fontSize(12)
          .fontColor('#1A2432')
          .height(32)
          .padding({ left: 14, right: 14 })
          .backgroundColor('#FFD878')
          .borderRadius(16)
          .onClick(() => {
            this.currentTabIndex = 1;
          })
      }
      .width('90%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor('rgba(22,28,38,0.42)')
      .borderRadius(24)
      .margin({ bottom: 12 })
    }
  }

  @Builder
  private buildCompanionPreview() {
    Row({ space: 14 }) {
      Column()
        .width(52)
        .height(52)
        .borderRadius(18)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(255,216,120,0.28)', 0],
            ['rgba(255,255,255,0.08)', 1]
          ]
        })

      Column({ space: 6 }) {
        Text('陪伴角色已在线')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(this.isRunning ? '猫咪正在陪你专注，这一轮就安心学下去。' : '开始一轮专注后，猫咪会继续在陪伴页和你互动。')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.72)')
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(`今日 ${this.tomatoCount} 个番茄，累计 ${this.totalTomatoCount} 个`)
          .fontSize(11)
          .fontColor('rgba(255,255,255,0.56)')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('90%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor('rgba(255,255,255,0.08)')
    .borderRadius(24)
    .margin({ bottom: 18 })
  }
}
