using System;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObjects/DialogueSegment")]
public class DialogueScriptableObject : ScriptableObject
{
    [Serializable]
    public struct Dialogue
    {
        public AudioClip Audio;
        [TextArea(2, 5)] public string Text;
        public float Delay;
    }

    public List<Dialogue> DialogueSegment;
}
