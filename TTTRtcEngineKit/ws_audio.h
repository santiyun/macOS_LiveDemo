#ifndef WS_AUDIO_H_
#define WS_AUDIO_H_
#include <stdint.h>
#include "TTTBase.h"

#include <vector>
namespace TTTRtc {
namespace ALib {
static const int kAdmMaxDeviceNameSize = 128;
static const int kAdmMaxFileNameSize = 512;
static const int kAdmMaxGuidSize = 128;
static const int kDefaultSendSSRC = 1;
static const int kDefaultRecvSSRC = 2;
static const int kMaxVolume = 100;
static const int kMinVolume = 0;
// static const int kDefaultEarphoneMonitorSSRC = 2;

class WsAudioDevice {
 public:
  virtual ~WsAudioDevice() {}
  virtual int16_t PlayoutDevices() = 0;
  virtual int16_t RecordingDevices() = 0;
  virtual int32_t PlayoutDeviceName(uint16_t index,
                                    char name[kAdmMaxDeviceNameSize],
                                    char guid[kAdmMaxGuidSize]) = 0;
  virtual int32_t RecordingDeviceName(uint16_t index,
                                      char name[kAdmMaxDeviceNameSize],
                                      char guid[kAdmMaxGuidSize]) = 0;
  virtual int32_t SetPlayoutDevice(uint16_t index) = 0;
  virtual int32_t SetRecordingDevice(uint16_t index) = 0;

  // Speaker volume controls
  virtual int32_t SpeakerVolumeIsAvailable(bool* available) = 0;  //应用程序音量
  virtual int32_t SetSpeakerVolume(uint32_t volume) = 0;
  virtual int32_t SpeakerVolume(uint32_t* volume) const = 0;
  virtual int32_t MaxSpeakerVolume(uint32_t* maxVolume) const = 0;
  virtual int32_t MinSpeakerVolume(uint32_t* minVolume) const = 0;

  virtual int32_t MicrophoneVolumeIsAvailable(
      bool* available) = 0;  //麦克风音量
  virtual int32_t SetMicrophoneVolume(uint32_t volume) = 0;
  virtual int32_t MicrophoneVolume(uint32_t* volume) const = 0;
  virtual int32_t MaxMicrophoneVolume(uint32_t* maxVolume) const = 0;
  virtual int32_t MinMicrophoneVolume(uint32_t* minVolume) const = 0;
};
// 目前跟ez_log对应
enum WsAudioLogLevel {
  LogLevel_Trace = 0,
  LogLevel_Debug = 1,
  LogLevel_Info = 2,
  LogLevel_Warn = 3,
  LogLevel_Error = 4,
  LogLevel_Fatal = 5,
};
typedef void (*WsAudioLogCbk)(WsAudioLogLevel loglevel, const char* str);
//跟webrtc中codec.id对应
enum WsAudioCodecProfile {
  kISAC_16k = 103,  //{103, "ISAC", 16000, 480, 1, 32000},
  kISAC_32k = 104,  //{104, "ISAC", 32000, 480, 1, 32000},
  kOpus_48k = 120,
  kAAC_48k = 121,    //{121, "AAC", 48000, 960, 1, 64000 },
  kHEAAC_48k = 122,  //{122, "HEAAC", 48000, 960, 1, 64000 },
};

struct WsAudioSendParameters {
  uint32_t ssrc = kDefaultSendSSRC;
  int32_t profile = kISAC_16k;  // WsAudioCodecProfile
  int32_t bitrate = 16000;      //-1: 保持默认码率
  int32_t channels = 1;
};

struct WsExtPcmConfig {
  bool enable_local = true;
  bool enable_remote = true;
  int32_t cache_ms = 500;
};

struct WsAudioFrame {
  uint8_t* data;   // PCM 16bit little endian
  int32_t length;  // samples_per_channel * num_channels * 2
  int32_t num_channels;
  int32_t samples_per_channel;
  int32_t sample_rate_hz;
  int64_t timestamp;
};

class WsAudioObserver {
 public:
  virtual ~WsAudioObserver() {}

  virtual void OnSendRtp(void* data, int32_t len) = 0;  //上行RTP
  virtual void OnSendRtcp(void* data, int32_t len) = 0;

  virtual void OnCaptureData(WsAudioFrame* frame) {}  // mic采集PCM 经过回声消除等处理
  virtual void OnCaptureDataMixed(WsAudioFrame* frame) {
  }  //本地上行PCM（内容同SendRtp）
  virtual void OnRenderData(uint32_t ssrc, int64_t uid, WsAudioFrame* frame) {
  }                                                       //单路远端PCM
  virtual void OnRenderDataMixed(WsAudioFrame* frame) {}  //所有远端混音后PCM

  // 房间里的所有声音混音，包括Local（麦克风）、Remote（远端音频）、ExtPcm的上行
  // 调用EnableAllDataMixedOutput接口控制是否进行混音并输出，混音时需要关掉耳返
  virtual void OnAllDataMixed(WsAudioFrame* frame) {}

  // active: 1 - (Active Voice), 0 - (Non-active Voice), -1 - (Error)
  virtual void OnLocalVadIndication(int active) {}
  virtual void OnRemoteVadIndication(uint32_t ssrc, int64_t uid, int active) {}
};

struct WsAudioSenderInfo {
  int32_t muted;  // 1: mute
  int32_t audio_level;  // 处理后的音量
  int32_t original_level; // 采集的原始音量

  int64_t rtt_ms;       // rtt
  int64_t cap_samples;  // 总采样点数
  // int32_t enc_bytes;                    // 总编码数据量
  int64_t bytes_encoded;
  int64_t bytes_sent;
  int64_t retransmitted_bytes_sent;
  float fraction_lost;
};

struct WsAudioReceiverInfo {
  //WsAudioReceiverInfo() {}
  //WsAudioReceiverInfo(uint32_t ssrc, int32_t delay_estimate_ms)
  //    : ssrc(ssrc), delay_estimate_ms(delay_estimate_ms) {}

  uint32_t ssrc;
  int32_t muted;
  int32_t audio_level;
  int64_t rtt_ms;

  int64_t bytes_rcvd;
  float fraction_lost;
  int32_t delay_estimate_ms;
  int32_t jitter_ms;
  int32_t jitter_buffer_ms;
  int32_t base_delay_ms;  // neteq base_target_level
  float secondary_discarded_rate;
  int64_t bytes_decoded;

  int32_t carton_ms;
  int32_t carton_count;
};

struct WsAudioInfo {
  WsAudioInfo() = default;
  ~WsAudioInfo() = default;
  WsAudioSenderInfo sender;
  std::vector<WsAudioReceiverInfo> receivers;
};

class TTT_API WsAudio {
 public:
  static WsAudio* GetInstance();
  virtual ~WsAudio() {}
  virtual int32_t Init() = 0;
  virtual int32_t Terminate() = 0;
  virtual bool Initialized() = 0;

  virtual void SetLog(WsAudioLogLevel level, WsAudioLogCbk cbk) = 0;

  virtual WsAudioDevice* Devices() = 0;

  virtual int32_t SetSendParameters(const WsAudioSendParameters& params) = 0;
  virtual WsAudioSendParameters GetSendParameters() = 0;

  virtual void StartSend() = 0;
  virtual void StopSend() = 0;

  //TODO:
  //virtual bool IsSendStarted() = 0;

  virtual int32_t AddRecvStream(uint32_t ssrc, int64_t uid = 0) = 0;
  virtual int32_t RemoveRecvStream(uint32_t ssrc) = 0;
  virtual void RecvRtp(uint8_t* data, int32_t len) = 0;
  virtual void RecvRtcp(uint8_t* data, int32_t len) = 0;

  /* volume: 0-100 100为原音量 */
  virtual void SetSendVolume(int32_t volume) = 0;
  virtual int32_t SendVolume() = 0;
  virtual void SetRecvStreamVolume(uint32_t ssrc, int32_t volume) = 0;
  virtual int32_t RecvStreamVolume(uint32_t ssrc) = 0;
  virtual void SetRecvStreamMixedVolume(int32_t volume) = 0;
  virtual int32_t RecvStreamMixedVolume(int32_t volume) = 0;

  virtual void MuteSendStream(bool mute) = 0;
  virtual void MuteRecvStream(uint32_t ssrc, bool mute) = 0;
  // mute: true 静音所有远端音频（ExtPcm除外）
  //       false 远端音频静音状态由 MuteRecvStream 设置
  virtual void MuteAllRecvStream(bool mute) = 0;

  virtual void EnableAllDataMix(bool enable) = 0;

  // mode: 0/1/2/3 值越大检测越严格
  virtual int32_t EnableLocalVAD(bool enable, int mode) = 0;
  virtual int32_t EnableRemoteVAD(uint32_t ssrc, bool enable, int mode) = 0;

  virtual int32_t GetStats(WsAudioInfo* info) = 0;
  virtual int32_t SetMinPlayoutDelay(uint32_t ssrc, int32_t delay_ms) = 0;
  virtual int32_t SetMaxPlayoutDelay(uint32_t ssrc, int32_t delay_ms) = 0;
  virtual uint32_t GetPlayoutTimestamp(uint32_t ssrc) = 0;

  // Gets the current microphone level(full range), as a value between 0 and
  // 32767.
  virtual int32_t GetInputLevel() = 0;
  virtual int32_t GetOutputLevel(uint32_t ssrc) = 0;  // TODO: add 0-10
  virtual void EnableEarphoneMonitor(bool enable) = 0;
  virtual void SetEarphoneMonitorVolume(int32_t volume) = 0;

  virtual int32_t ExtPcmCreate(WsExtPcmConfig* config) = 0;
  virtual void ExtPcmRelease(int32_t id) = 0;
  virtual void ExtPcmReconfigure(
      int32_t id,
      WsExtPcmConfig* config) = 0;  // TODO: 暂未实现修改cache_ms功能
  virtual bool ExtPcmPushFrame(int32_t id, WsAudioFrame* frame) = 0;
  virtual void ExtPcmClearCache(int32_t id) = 0;
  virtual void ExtPcmSetPaused(int32_t id, bool paused) = 0;
  virtual bool ExtPcmSetVolume(int32_t id,
                               int32_t local_volume,
                               int32_t remote_volume) = 0;
  virtual bool ExtPcmGetVolume(int32_t id,
                               int32_t& local_volume,
                               int32_t& remote_volume) = 0;
  virtual bool ExtPcmGetLevel(int32_t id,
                              int32_t& local_level,
                              int32_t& remote_level) = 0;

  virtual int32_t RegisterObserver(WsAudioObserver* observer) = 0;  // return id
  virtual void UnregisterObserver(int id) = 0;
};
}  // namespace ALib
}  // namespace TTTRtc

#endif  // WS_AUDIO_H_