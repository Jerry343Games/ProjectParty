using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InstanceMilkBox : MonoBehaviour
{
    public GameObject cargo;
    public Vector3 dropArea;
    public Vector3 dropCenter;
    public Vector2 minMax;
    private float durTime;
    private bool ableToDrop;
    private Vector3 area;

    public GameObject dropEffect;
    public float startTime;
    bool startWaitting;
    // Start is called before the first frame update
    void Start()
    {
        ableToDrop = true;
        startWaitting = false;
        StartCoroutine(WaitStart(startTime));
    }

    // Update is called once per frame
    void Update()
    {
        if (PlayerIndentify.isStartGame&&startWaitting)
        {

            Drop();            
        }
    }

    void Drop()
    {
        if (ableToDrop)
        {
            area.x = Random.Range((dropCenter.x-dropArea.x/2),(dropCenter.x+dropArea.x/2));
            area.y = Random.Range((dropCenter.y - dropArea.y / 2),(dropCenter.y + dropArea.y / 2));
            area.z = Random.Range((dropCenter.z - dropArea.z / 2), (dropCenter.y + dropArea.z / 2));

            durTime = Random.Range(minMax.x, minMax.y);
            Instantiate(dropEffect, area, Quaternion.identity);
            Instantiate(cargo, area, Quaternion.identity);
            ableToDrop = false;
            StartCoroutine(WaitToDrop(durTime));
        }
                
    }

    IEnumerator WaitToDrop(float dur)
    {
        yield return new WaitForSeconds(dur);
        ableToDrop = true;
    }
    IEnumerator WaitStart(float time)
    {
        yield return new WaitForSeconds(time);
        startWaitting = true;
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireCube(dropCenter, dropArea);
    }
}
