using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using TMPro;

public class DialogueMaster : MonoBehaviour
{
    [Serializable]
    public struct DialogueSegment
    {
        public UnityEvent Event;
        public DialogueScriptableObject Dialogue;
    }

    [SerializeField] private List<DialogueSegment> _dialogues;
    [SerializeField] private int _dialogueIndex;
    [SerializeField] private AudioSource _audioSource;
    [SerializeField] private TextMeshProUGUI _textField;
    private bool _isCoroutineRunning = false;

    public enum DialogueState { Idle, Playing };
    public DialogueState _dialogueState;

    void Start()
    {
        _dialogueIndex = 0;
        _dialogueState = DialogueState.Idle;
    }

    void Update()
    {
        CheckAudioSource();
    }

    public void PlaySegment(int index)
    {
        if (index <= _dialogues.Count - 1 && !_isCoroutineRunning)
        {
            StartCoroutine(AudioPlayer(index));
        }
    }

    IEnumerator AudioPlayer(int index)
    {
        _isCoroutineRunning = true;
        foreach (DialogueScriptableObject.Dialogue dialouge in _dialogues[index].Dialogue.DialogueSegment)
        {
            yield return new WaitUntil(() => _dialogueState == DialogueState.Idle);
            yield return new WaitForSecondsRealtime(dialouge.Delay);
            _audioSource.PlayOneShot(dialouge.Audio);
            _dialogueState = DialogueState.Playing;
            _textField.SetText(dialouge.Text);
        }
        _isCoroutineRunning = false;
        _textField.SetText("");

        _dialogues[index].Event!.Invoke();
    }

    private void CheckAudioSource()
    {
        if (!_audioSource.isPlaying)
        {
            _dialogueState = DialogueState.Idle;
        }
    }
}
