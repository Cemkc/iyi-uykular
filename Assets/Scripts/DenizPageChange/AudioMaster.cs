using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioMaster : MonoBehaviour
{
    [SerializeField] private List<AudioClip> _audioClips;

    public void PlaySound(int index, Vector3 position, float volume)
    {
        if (index <= _audioClips.Count - 1)
        {
            AudioSource.PlayClipAtPoint(_audioClips[index], position, volume);
        }
    }
}
