using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cannon : MonoBehaviour
{
    public GameObject fireEffect;
    public Transform firePosion;
    public GameObject boom;
    public Transform cannon;
    public float exisitTime;
    public GameObject destoryEffect;
    
    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(FireCanaon());
        Destroy(gameObject, exisitTime);
        StartCoroutine(DIsableEffect());
    }

    // Update is called once per frame
    void Update()
    {
       
    }

    IEnumerator FireCanaon()
    {

        while (true)
        {
            
            yield return new WaitForSeconds(2);
            //判断炮口朝向
            if (cannon.rotation.y == 1f)
            {  
                Instantiate(fireEffect, firePosion.transform.position, Quaternion.Euler(0, 0, 90));
                //Debug.Log(cannon.rotation.y);
            }
            if (cannon.rotation.y == 0f)
            {
                Instantiate(fireEffect, firePosion.transform.position, Quaternion.Euler(0, 0, -90));
            }
            if (cannon.rotation == Quaternion.Euler(0, -90, 0))
            {
                Instantiate(fireEffect, firePosion.transform.position, Quaternion.Euler(90, 0, 0));
            }
            if (cannon.rotation == Quaternion.Euler(0,90,0))
            {
                Instantiate(fireEffect, firePosion.transform.position, Quaternion.Euler(-90, 0, 0));
            }

            SoundsManager.PlayCannonFireAudio();
            Instantiate(boom, firePosion.transform.position, transform.rotation/*Quaternion.Euler(0, 0, 0)*/);
            print("DoSomething Loop");

            //设置间隔时间为10秒


        }

    }
    IEnumerator DIsableEffect()
    {
        yield return new WaitForSeconds(exisitTime-0.5f);
        Instantiate(destoryEffect, transform.position, Quaternion.Euler(90, 0, 0));

    }
}
